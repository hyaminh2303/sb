json.campaigns do
  json.array! @campaigns do |c|
    json.id c.id
    json.name c.name
    json.user_name c.user_name
    json.start_time c.start_time.strftime(Date::DATE_FORMATS[:date_time_default])
    json.end_time c.end_time.strftime(Date::DATE_FORMATS[:date_time_default])
    json.pricing_model c.pricing_model
    json.created_at c.created_at.strftime(Date::DATE_FORMATS[:date_time_default])
    json.status c.status
    json.health "#{(c.health(false) * 100).round(2)} %"
    json.update_status_by c.updated_status_by
  end
end
  
json.count @count
