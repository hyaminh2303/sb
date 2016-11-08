# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
if User.count == 0
  u = User.create(email: 'ops@yoose.com', password: 'password123', name: 'Ops', company: 'YOOSE', confirmed_at: Time.now, approved: true)
  u.add_role :admin
end
# puts "Truncate table #{Cost.table_name}..."
# ActiveRecord::Base.connection.execute("TRUNCATE #{Cost.table_name};")
# puts 'Create random cost data...'
# Country.all.each do |country|
#     CampaignType.all.each do |type|
#       price = Money.new(rand(100..100000), 'USD')
#       puts "create cost: {country: #{country.name}, pricing_model: #{type.name}, price: #{price.dollars}}"
#       Cost.create({country_id: country.id, pricing_model: type.name, price: price})
#     end
# end
# puts 'Create random cost data done.'
