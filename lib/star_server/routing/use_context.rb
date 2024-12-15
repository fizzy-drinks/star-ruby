require_relative "context_validator"

module Star
  module Routing
    class UseContext
      def initialize(request)
        @request = request
        @properties = {}
      end

      def headers(&block)
        validation = ContextValidator.new(request.headers)
        validation.instance_exec(&block)
        properties.merge!(validation.properties)
      end

      def query(&block)
        validation = ContextValidator.new(request.query)
        validation.instance_exec(&block)
        properties.merge!(validation.properties)
      end

      def body(&block)
        validation = ContextValidator.new(request.body || {})
        validation.instance_exec(&block)
        properties.merge!(validation.properties)
      end

      attr_reader :request, :properties
    end
  end
end
