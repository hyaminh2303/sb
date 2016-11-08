class Country < ActiveRecord::Base


  # region Use shared table
  self.table_name_prefix = ''
  # endregion

  has_many :costs
  has_many :cities

  # countries with defined CPC, CPM price
  scope :valid_countries, ->() do
    joins(:costs).group('country_code')
  end
  # region DSP Mapping

  include DspMapping
  has_dsp_mapping

  #endregion
  alias_attribute :code, :country_code
end
