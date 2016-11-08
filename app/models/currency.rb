class Currency < ActiveRecord::Base
  def self.usd(money, currency_code)
    currency =  Money::Currency.new(currency_code)
    Money.new(money * currency.subunit_to_unit, currency).as_us_dollar
  end

  def self.money(money, currency_code)
    currency =  Money::Currency.new(currency_code)
    Money.new(money * currency.subunit_to_unit, currency)
  end
end
