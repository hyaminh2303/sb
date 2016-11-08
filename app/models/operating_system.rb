class OperatingSystem < ActiveRecord::Base

  # region Use shared table
  self.table_name_prefix = ''
  # endregion

  # region DSP Mapping

  include DspMapping
  has_dsp_mapping

  #endregion

  has_many :device_os_trackings

  class << self
    def other
      find_by(name: 'Others')
    end
  end
end
