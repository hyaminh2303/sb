class CampaignsStatsSerializer < ActiveModel::Serializer
  include ActionView::Helpers::NumberHelper

  attributes :id, :name, :start_time, :end_time, :views, :clicks, :target_impression, :target_click, :ctr, :budget_spent, :actual_budget, :actions, :status, :remaining_budget, :company, :updated_status_by, :campaign_end_time

  def status
    object.id.present? ? object.status : 'hidden'
  end

  def name
    object.id.present? ? object.name : 'Total'
  end

  def start_time
    object.start_time.to_date.to_formatted_s(:short_date) if object.id.present?
  end

  def end_time
    object.end_time.to_date.to_formatted_s(:short_date) if object.id.present?
  end

  def views
    number_with_delimiter(object.views)
  end

  def clicks
    number_with_delimiter(object.clicks)
  end

  def ctr
    "#{object.ctr.round(2)}%"
  end

  def company
    return if !object.has_attribute?(:user_id)
    user = {}
    user['company'] = object.user.company
    user
  end

  def budget_spent
    object.budget_spent.format
  end

  def actual_budget
    return if !object.has_attribute?(:budget_cents)
    object.budget.format if object.budget.present?
  end

  def remaining_budget
    return if !object.has_attribute?(:budget_cents)
    if object.budget.present?
      (object.budget - object.budget_spent).to_f
    else
      0.0
    end
  end

  def target_impression
    number_with_delimiter(object.target_impression) if object.id.present?
  end

  def target_click
    number_with_delimiter(object.target_click) if object.id.present?
  end

  def actions

  end

  def status
    if object.id.present?
      object.status.nil? ? :pending : object.status
    end
  end

  def updated_status_by
    return if !object.has_attribute?(:updated_status_by)
    object.updated_status_by.present? ? object.updated_status_by : ''
  end

  def campaign_end_time
    object.end_time.to_date if object.id.present?
  end

end