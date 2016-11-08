class AdExchange < ActiveRecord::Base

  include DspMapping
  has_dsp_mapping
  has_many :ad_exchange_dsp_mappings

  class << self
    def update_ad_exchange
      ad_exchanges = Bidstalk::MetaData::Client.new('exchange', 'exchange').list
      dsp_id = Platform.bidstalk.id
      ad_exchanges.each do |ad|
        exchange = AdExchange.find_or_create_by(id: ad[:id], name: ad[:name], ad_exchange_code: ad[:name].upcase )
        dsp_info = exchange.ad_exchange_dsp_mappings.find_by(dsp_id: dsp_id)
        if dsp_info.nil?
          exchange.ad_exchange_dsp_mappings.create(dsp_id: dsp_id, ad_exchange_dsp_id: ad[:id])
        else
          dsp_info.update_attribute(:ad_exchange_dsp_id, ad[:id])
        end
      end   
    end
  end

end
