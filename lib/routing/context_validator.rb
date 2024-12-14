module Star
  module Routing
    class ContextValidator
      def initialize(data)
        @data = data
      end

      attr_reader :data, :properties

      def method_missing(method, klass)
        value = data[method.to_s]
        raise ValidationError, "#{method} is not of type #{klass.name}!" unless value.is_a?(klass)

        @properties ||= {}
        @properties[method.to_s] = value
      end

      def respond_to_missing? = true
    end

    class ValidationError < StandardError; end
  end
end
