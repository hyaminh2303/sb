class API::StatsController < InheritedResources::Base
  respond_to :json

  has_scope :page, default: 1
  has_scope :per, default: 10

  def campaigns
    
    stats = apply_scopes(Campaign).launched(current_user).statistics(period).order_with_default(order_field, sort_type).search(search_by, search_term)
    total_stats = Campaign.launched(current_user)

    session[:search_by_company] = params[:account]

    if params[:company].present?
      stats = stats.by_company(params[:company])
      total_stats = total_stats.by_company(params[:company])
    end

    stats.unshift(total_stats.total_statistics(period)) if stats.size > 1
    respond_with stats, each_serializer: CampaignsStatsSerializer
  end

  def total_campaigns
    total_stats = Campaign.launched(current_user).statistics(period).search(search_by, search_term).unscope(:select, :limit, :offset)
    if params[:company].present?
      total_stats = total_stats.by_company(params[:company])
    end
    total_size = total_stats.count

    respond_with({total_size: total_size})
  end

  def views
    stats = Stats::BaseStats.get_type(:views, current_user, params)
    daily_trackings = stats.views
    render json: {category: daily_trackings.keys, data: daily_trackings.values}
  end

  def clicks
    stats = Stats::BaseStats.get_type(:clicks, current_user, params)
    daily_trackings = stats.clicks
    render json: {category: daily_trackings.keys, data: daily_trackings.values}
  end

  def budget_spent
    stats = Stats::BaseStats.get_type(:budget_spent, current_user, params)
    daily_trackings = stats.budget_spent
    render json: {category: daily_trackings.keys, data: daily_trackings.values}
  end

  def period
    if permitted_params[:start_date].present? && permitted_params[:end_date].present?
      [Date.parse(permitted_params[:start_date]), Date.parse(permitted_params[:end_date])]
    else
      [1.week.ago.to_date, Date.today]
    end
  end

  def search_by
    permitted_params[:search_by]
  end

  def search_term
    permitted_params[:search_term]
  end

  def order_field
    permitted_params[:sort_by]
  end

  def sort_type
    permitted_params[:order_by].upcase
  end

  def permitted_params
    params.permit(:page, :per, :sort_by, :order_by, :search_by, :search_term, :start_date, :end_date)
  end
end