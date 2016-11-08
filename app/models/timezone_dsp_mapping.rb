class TimezoneDspMapping < ActiveRecord::Base

  # region Use shared table

  self.table_name_prefix = ''
  self.table_name = self.table_name.singularize

  # endregion

  belongs_to :timezone
end
