class Cost < ActiveRecord::Base
  belongs_to :country
  monetize :price_cents

  # region Validation
  
  validates :pricing_model, :price_currency, length: {:maximum => 255}

  # endregion
end
