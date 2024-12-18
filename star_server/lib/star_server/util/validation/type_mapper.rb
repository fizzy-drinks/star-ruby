require "date"

module Star
  module Util
    module Validation
      module TypeMapper
        def map_to_type(property, value)
          raise ValidationError, "#{property.name} cannot be nil" if property.required && value.nil?

          return value if value.nil? || value.is_a?(property.datatype)

          case
          when property.datatype == DateTime && value.is_a?(Time)
            return DateTime.iso8601(value.iso8601)
          when property.datatype == DateTime
            return DateTime.iso8601(value.to_s)
          when property.datatype == String
            return value.to_s
          end

          raise ValidationError, "#{value} cannot be converted to #{property.datatype.name}"
        rescue Date::Error => e
          raise ValidationError, e.message
        end
      end

      class ValidationError < StandardError; end
    end
  end
end
