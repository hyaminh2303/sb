class CostSerializer < ActiveModel::Serializer
  attributes :id, :country, :pricing_model, :price

  def price
    object.price.dollars
  end
end
