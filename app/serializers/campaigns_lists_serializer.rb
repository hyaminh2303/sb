class CampaignsListsSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_name, :start_time, :end_time, :pricing_model, :created_at, :status

  def user_name
    object.user.name
  end

  def start_time
    object.start_time.strftime(Date::DATE_FORMATS[:date_time_default])
  end

  def end_time
    object.end_time.strftime(Date::DATE_FORMATS[:date_time_default])
  end

  def created_at
    object.created_at.strftime(Date::DATE_FORMATS[:date_time_default])
  end
end
