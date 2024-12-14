require_relative "../util/validation/type_mapper"
require_relative "../builders/property_builder"

module Star
  module Routing
    class ContextValidator
      include Util::Validation::TypeMapper

      def initialize(data)
        @data = data
      end

      attr_reader :data, :properties

      def method_missing(method, &block)
        property = Builders::PropertyBuilder.build(method.to_s, &block)
        value = map_to_type(property, data[method.to_s])

        @properties ||= {}
        @properties[method.to_s] = value
      end

      def respond_to_missing? = true
    end
  end
end
