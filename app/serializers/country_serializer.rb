class CountrySerializer < ActiveModel::Serializer
  attributes :id, :name, :code

  def code
    object.country_code
  end
end
