class CountryDspMapping < ActiveRecord::Base

  # region Use shared table

  self.table_name_prefix = ''
  self.table_name = self.table_name.singularize

  # endregion

  # region Associations

  belongs_to :country

  # endregion

end
