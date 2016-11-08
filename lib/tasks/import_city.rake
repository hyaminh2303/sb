namespace :self_booking do
  task import_city: :environment do
    dsp = Platform.bidstalk
    client = Bidstalk::MetaData::Client.new('state', 'state'.gsub(/_/, '/'))
    client.list.each do |city|
      country_dsp_mapping = CountryDspMapping.find_by( dsp_id: dsp.id, country_dsp_id: city[:country_id] )
      next if country_dsp_mapping.blank?
      c = City.find_or_create_by(name: city[:name], country_id: country_dsp_mapping.country_id)
      c.dsp.find_or_create_by(name: city[:name], dsp_id: dsp.id, city_dsp_id: city[:id], country_dsp_mapping_id: country_dsp_mapping.id)
    end
  end
end