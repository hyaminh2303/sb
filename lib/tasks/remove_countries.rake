namespace :self_booking do
  desc "Remove the countries that are not on the list"
  task remove_contries: :environment do
    arr_country_name = ["United Kingdom", "Germany", "France", "Romania", "United Arab Emirates", "Qatar", "Saudi Arabia", "Bahrain", "Singapore", "Vietnam", "Indonesia", "Philippines", "Thailand", "Australia", "New Zealand", "United States"]
    Country.where.not(name: arr_country_name).destroy_all
  end
end