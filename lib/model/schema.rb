require_relative "../util/validation/type_mapper"
require_relative "../util/validation/property"

module Star
  class Model
    class Schema
      include Util::Validation::TypeMapper

      def initialize
        @properties = {}
      end

      attr_reader :properties

      def map(data)
        data.each_with_object({}) do |(key, value), obj|
          property = properties[key.to_sym]
          value = map_to_type(property, value)

          obj[key] = value
        end
      end

      def add_property(property)
        @properties[property.name] = property
      end

      def to_json(*)
        {properties:}.to_json(*)
      end
    end
  end
end
