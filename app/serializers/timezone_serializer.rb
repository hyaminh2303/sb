class TimezoneSerializer < ActiveModel::Serializer
  attributes :id, :name, :code

  def code
    object.zone
  end
end
