module DspMapping
  def self.included(base)
    base.extend(ClassMethods)
  end

  def dsp_info(dsp_id)
    self.dsp.find_by(dsp_id: dsp_id)
  end

  module ClassMethods
    def has_dsp_mapping(class_mapping=nil)
      class_mapping = class_mapping || "#{name}DspMapping"
      has_many :dsp, class_name: class_mapping
    end
  end
end