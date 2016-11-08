module Reports::Models::TrackingRecord
  include ActionView::Helpers::NumberHelper
  include Reports::Helpers::CampaignReportHelper

  attr_reader :time
  attr_reader :views
  attr_reader :clicks
  attr_reader :impressions
  attr_reader :ctr
  attr_reader :spend
  attr_reader :number_of_device_ids
  attr_reader :frequency_cap
  attr_reader :date_range


  def date_formatted
    @date.strftime(Date::DATE_FORMATS[:iso])
  end

  def ctr_formatted
    if @ctr.nil?
      return I18n.t('statuses.not_available')
    end
    "#{(@ctr * 100).round(2)}%"
  end

  def spend_formatted
    @spend.format
  end


  def hash_detail
    # JSON.parse to_json, {:symbolize_names => true}
    json = {
        views: number_with_delimiter(@views),
        clicks: number_with_delimiter(@clicks),
        ctr: ctr_formatted
    }
    unless @impressions.nil?
      json[:impressions] = number_with_delimiter(@impressions)
    end
    unless @number_of_device_ids.nil?
      json[:number_of_device_ids] = number_with_delimiter(@number_of_device_ids)
    end
    unless @spend.nil?
      json[:spend] = spend_formatted
    end
    unless @time.nil?
      json[:time] = @time
    end
    unless @date_range.nil?
      json[:date_range] = number_with_delimiter(@date_range)
    end
    unless @device_ids_vs_views.nil?
      json[:device_ids_vs_views] = number_to_percentage(@device_ids_vs_views.to_f * 100)
    end
    unless @frequency_cap.nil?
      json[:frequency_cap] = number_with_delimiter(@frequency_cap)
    end

    json
  end

  protected
  def init_detail(detail, campaign = nil)
    if detail.attribute_present?(:date)
      @date = detail.date
      @time = detail.date.to_time.to_i
    else
      @date = nil
      @time = nil
    end

    if detail.respond_to?(:views)
      @views = detail.views
    end
    if detail.respond_to?(:clicks)
      @clicks = detail.clicks
    end

    if detail.respond_to?(:impressions)
      @impressions = detail.impressions
    end

    if detail.respond_to?(:number_of_device_ids)
      @number_of_device_ids = detail.number_of_device_ids
      @device_ids_vs_views = (@number_of_device_ids.to_f/@views.to_f)
    end
    if detail.respond_to?(:frequency_cap)
      @frequency_cap = detail.frequency_cap
    end
    if detail.respond_to?(:date_range)
      @date_range = detail.date_range
    end
    unless campaign.nil?
      @spend = get_spend(detail, campaign)
    end
    @ctr = get_ctr(detail)
  end
end
