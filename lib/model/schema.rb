module Star
  class Model
    class Schema
      def initialize
        @properties = {}
      end

      attr_reader :properties

      def map(data)
        data.each_with_object({}) do |(key, value), obj|
          property = properties[key.to_sym]
          klass = property.datatype

          unless value.nil? || value.is_a?(klass) || (value = map_to_type(klass, value))
            raise SchemaError, "Property #{key} is not of type #{klass.name}!"
          end

          obj[key] = value
        end
      end

      def map_to_type klass, value
        return if value.nil?

        if klass == DateTime
          DateTime.iso8601(value)
        elsif klass == String
          value.to_s
        end
      rescue Date::Error => e
        raise SchemaError, e.message
      end

      def add_property(property)
        @properties[property.name] = property
      end

      def to_json(*)
        {properties:}.to_json(*)
      end

      Property = Struct.new(
        "Property", :name, :datatype, :required, :default_proc, keyword_init: true
      ) do
        def to_json(*)
          {name:, type: datatype, required:, has_default: !default_proc.nil?}.to_json(*)
        end
      end

      class SchemaError < StandardError; end
    end
  end
end
