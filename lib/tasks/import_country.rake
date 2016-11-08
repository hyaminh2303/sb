namespace :self_booking do
  task import_country: :environment do
    unless Country.where(country_code: 'TR', name: 'Turkey').exists?
      country = Country.create(country_code: 'TR', name: 'Turkey')
      country.dsp.create(dsp_id: Platform.bidstalk.id, country_dsp_id: 238, country_code: "238")
      country.costs.create(pricing_model: 'CPM', price_cents: 300, price_currency: 'USD')
      country.costs.create(pricing_model: 'CPC', price_cents: 30, price_currency: 'USD')
    end
  end
end