class Category < ActiveRecord::Base

  # region Use shared table

  self.table_name_prefix = ''

  # endregion

  # region DSP Mapping

  include DspMapping
  has_dsp_mapping
  has_many :category_dsp_mappings

  # endregion

  # region Associations

  has_many :categories, class_name: 'Category', foreign_key: 'parent_id'
  has_many :category_dsp_mappings
  belongs_to :parent, class_name: 'Category'

  delegate :name, to: :parent, prefix: true, allow_nil: true
  # endregion

  scope :platform_parent_categories, ->(platform) {joins(:category_dsp_mappings).where(category_dsp_mapping: {dsp_id: platform.id}).where(parent_id: nil).distinct}
  scope :all_parent_categories, ->{where(parent_id: nil).distinct}

  # region Class Methods

  def self.all_groups
    groups = {}
    self.where(parent_id: 0).each do |p|
      p.categories.each do |c|
        (groups[p.name] ||= []) << [c.name, c.id]
      end
    end
    groups
  end

  def self.grouped
    Rails.cache.fetch(:grouped_categories) do
      groups = []
      self.where(parent_id: 0).each do |p|
        groups << [p.name, Category.select{|c| c.parent_id == p.id }]
      end
      groups
    end
  end


  #endregion

end
