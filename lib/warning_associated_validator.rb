module ActiveRecord
  module Validations
    class WarningAssociatedValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        Array.wrap(value).each do |v|
          unless v.valid?
            v.errors.full_messages.each do |msg|
              record.errors.add(attribute, msg, options.merge(:value => value))
            end
          end
        end
      end
    end

    module ClassMethods
      def validates_associated!(*attr_names)
        validates_with WarningAssociatedValidator, _merge_attributes(attr_names)
      end
    end
  end
end