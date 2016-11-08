class CityDspMapping < ActiveRecord::Base
  belongs_to :city
  belongs_to :platform
  belongs_to :country_dsp_mapping

  delegate :name, to: :city

end
