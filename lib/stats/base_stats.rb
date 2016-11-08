module Stats
  class BaseStats
    DATA_TYPES = [:views, :clicks, :budget_spent]

    def initialize(data_type, user, params)
      set_attributes(data_type, user, params)
    end

    def self.get_type(data_type, user, params)
      is_campaign = params[:campaign_id].to_i > 0
      if is_campaign
        CampaignStats.new(data_type, user, params)
      else
        TotalCampaignStats.new(data_type, user, params)
      end
    end

    def budget_spent
      raise NotImplementedError, "You should implement this method"
    end

    def clicks
      field_stats(@data_type)
    end

    def views
      field_stats(@data_type)
    end

    protected

    def field_stats(field)
      raise NotImplementedError, "You should implement this method"
    end

    private

    def array_to_hash(arr)
      Hash[arr.map { |m| [m.date.to_time.to_i*1000, m[data_type].to_f/100] }]
    end

    def set_attributes(data_type, user, params)
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]).to_formatted_s(:db) : 2.year.ago.to_date
      @end_date = params[:end_date].present? ? Date.parse(params[:end_date]).to_formatted_s(:db) : 1.year.since.to_date
      @campaign_id = params[:campaign_id]
      @name_kw = params[:search_term]
      @data_type = data_type
      @user = user
      @company = params[:company] || "ALL"
    end
  end
end