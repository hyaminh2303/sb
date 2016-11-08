require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
API_KEY = 'AIzaSyCFPoGJGFCNk8XXfY8Ur0zrQYMsLpswLKM'

namespace :self_booking do
  task :import_city_location => :environment do
    count = 0
    City.offset(2401).limit(2500).each do |city|
      result = URI.parse("https://maps.googleapis.com/maps/api/geocode/json?address=#{CGI::escape(city.name)}&key=#{API_KEY}").read
      result = JSON.parse(result)
      p result
      next if result['results'].size == 0
      count += 1
      location = result['results'][0]['geometry']['location']
      city.update(latitude: location['lat'], longitude: location['lng'])
    end
    p "Total #{count} city locations imported"
  end
end
