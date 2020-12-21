module Spree
  module VendorHelper

    def show_errors(object, field_name)
      if object && object.errors.any?
        if !object.errors.messages[field_name].blank?
          "#{"#{field_name}".split('_').join(' ')} #{object.errors.messages[field_name].join(' and ')}".capitalize
        end
      end
    end  
    
    def is_error(object, field_name)
      object && object.errors.any? && !object.errors.messages[field_name].blank? ? true : false
    end
  
    def error_class(object, field_name)
      is_error(object, field_name) ? 'is-invalid' : ''
    end
  
  end
end
