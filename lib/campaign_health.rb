module CampaignHealth
  def sum_daily
    sum_daily = MongoDb::DailyStat.where(campaign_id: self.id,
                                          timestamp: {:$lte => Time.now.end_of_day})

    dsp_daily = CampaignDspInfo.sum_daily_record self

    @total_views = [sum_daily.sum(:views), dsp_daily.views].max
    @total_clicks = [sum_daily.sum(:clicks), dsp_daily.clicks].max
  end

  def delivery_of_target
    delivery_realized
  end

  def total_days
    (end_time.to_date - start_time.to_date + 1).to_i
  end

  def days_left
    (end_time.to_date - Date.today + 1).to_i
  end

  def delivery_realized
    get_delivery_realized(@total_views, @total_clicks)
  end

  def delivery_expected(yesterday = false)
    get_delivery_expected(yesterday)
  end

  def health(yesterday)
    get_health delivery_realized, delivery_expected(yesterday)
  end

  def delivery_realized_percent
    (delivery_realized * 100).round(2)
  end

  def delivery_expected_percent(yesterday=false)
    (delivery_expected(yesterday) * 100).round(2)
  end

  def health_percent(yesterday = false)
    (health(yesterday) * 100).round(2)
  end

  def daily_pacing
    if Time.now.to_date < start_time.to_date
      # Future campaign
      days = (end_time.to_date - start_time.to_date + 1).to_i
    elsif Time.now.to_date > end_time.to_date
      # Past campaign
      return 0
    else
      days = (end_time.to_date - Time.now.to_date + 1).to_i
    end

    sum_yesterday = MongoDb::DailyStat.where(campaign_id: self.id,
                                          timestamp: {:$lte => (Date.today -1).end_of_day})
    total_views = sum_yesterday.sum(:views)
    total_clicks = sum_yesterday.sum(:clicks)

    remaining = self.target - (CPM? ? total_views : total_clicks)
    days == 0 ? remaining.to_f / 1 : remaining.to_f / days.to_f
  end

  private
  def get_delivery_realized(total_views, total_clicks)
    value = CPM? ? total_views : total_clicks
    self.target == 0 ? 0.0 : value.to_f / target.to_f
  end

  def get_delivery_expected(yesterday=false)
    if self.target == 0 
      return 0.0
    end

    if Time.now.to_date > end_time.to_date
      return 1.0
    elsif Time.now.to_date < start_time.to_date
      return 0.0
    end

    _target = self.target.to_f
    number_of_day = (end_time.to_date - start_time.to_date + 1).to_i.to_f
    days_left = (end_time.to_date - (yesterday ? Time.now.yesterday.to_date : Time.now.to_date)).to_i.to_f

    ((_target / number_of_day) * (number_of_day - days_left)) / _target
  end

  def get_health(realized, expected)
    realized - expected
  end
end
