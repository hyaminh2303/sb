class CampaignType < ActiveRecord::Base
  # region Use shared table

  self.table_name_prefix = ''

  # endregion

  # region DSP Mapping

  include DspMapping
  has_dsp_mapping

  # endregion

  class << self
    def cpc
      find_by(name: 'CPC')
    end
  end
end
