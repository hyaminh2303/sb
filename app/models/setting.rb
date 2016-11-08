class Setting < RailsSettings::CachedSettings
  self.table_name = 'sb_settings'

  # region Fixed Settings

  def self.site_title
    self['site.title']
  end

  # endregion

  # region Validation
  
  validates :var, length: {:maximum => 255}
  validates :thing_type, length: {:maximum => 30}

  # endregion
end
