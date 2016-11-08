module Reports::Campaigns::Base

  attr_reader :data
  attr_reader :total
  attr_reader :campaign
  attr_reader :records_total
  # to indicate whether to show ads group column or not
  attr_reader :ads_group_hidden

  def get_filename
    "#{@campaign.name.downcase.gsub(' ', '_')}_report_#{Time.now.strftime Date::DATE_FORMATS[:iso]}"
  end

  def length
    @campaign_details.length
  end

  def data_to_hash
    @data.map do |d|
      d.hash
    end
  end

  def total_to_hash
    @total.hash
  end

  protected
  def init_campaign(options)
    unless options[:id].nil?
      @campaign = Campaign.find options[:id]
    else
      unless options[:campaign_id].nil?
        @campaign = Campaign.find options[:campaign_id]
      else
        raise StandardError
      end
    end
  end

  def query(model_class, select, group, join)
    unless join.nil?
      query = model_class.select(select).joins(join).where(where_condition(@options)).group(group).order("#{get_order_column(order_index(@options))} #{order_sort(@options)}")
    else
      query = model_class.select(select).where(where_condition(@options)).group(group).order("#{get_order_column(order_index(@options))} #{order_sort(@options)}")
    end

    @records_total = query.length

    if @options[:length].nil?
      @campaign_details = query
    else
      @campaign_details = query.page(page(@options)).per(@options[:length].to_i)
    end
  end

  def page(params)
    if params[:start].nil? or params[:length].nil?
      return 1
    end

    (params[:start].to_i / params[:length].to_i) + 1
  end

  def order_sort(params)
    if params[:order].nil? || params[:order]['0'][:dir].nil?
      return 'ASC'
    end

    params[:order]['0'][:dir].upcase
  end

  def order_index(params)
    if params[:order].nil?
      return -1
    end

    params[:order]['0'][:column].to_i
  end

  def where_condition(params)
    unless params[:campaign_id].nil?
      condition = { campaign_id: params[:campaign_id]}
    else
      condition = { id: params[:id]}
    end

    # if @campaign.has_ads_group?
    #   unless params[:group_id].nil?
    #     condition[:group_id] = params[:group_id]
    #   end
    # end

    condition
  end
end
