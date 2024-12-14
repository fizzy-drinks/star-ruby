module Star
  class Router
    def initialize(app)
      @app = app
      @routes = []
    end

    attr_reader :app, :routes

    def route_match?(uri, matcher)
      re = %r{^#{matcher.gsub(/\{[^{}\/]+\}/, "[^/]+")}/?$}
      uri == matcher || uri =~ re
    end

    def handle(request)
      request => { method:, uri: }

      res = Response.new(headers: {"Content-Type" => "application/json"}, status: 200, request:)
      route = routes.find { |route| route_match?(uri, route.matcher) && route.method.to_s.upcase == method.upcase }
      unless route
        res.status = 404
        res.body = {message: "Not found"}.to_json
        return res
      end

      segments = uri.gsub(%r{^/+(.*)/+$}, '\1').split("/").reject(&:empty?)
      matcher_segments = route.matcher.gsub(%r{^/+(.*)/+$}, '\1').split("/").reject(&:empty?)
      matcher_segments.each_with_index do |segment, i|
        variable = segment.sub(/^{(.*)}$/, '\1')
        next segment if variable == segment

        res.define_singleton_method(variable.to_sym) { segments[i] }
      end

      res.body = res.instance_exec(request, &route.handler)
      res
    rescue ValidationError, Model::Schema::SchemaError => e
      res.body = {message: e.message}.to_json
      res.status = 400
      res
    end

    Response = Struct.new(:Response, :app, :request, :status, :body, :headers, keyword_init: true) do
      def use(&block)
        using ||= UseContext.new(request)
        using.instance_exec(&block) if block
        using.properties.each do |key, value|
          define_singleton_method(key.to_sym) { value }
        end
      end
    end

    class UseContext
      def initialize(request)
        @request = request
        @properties = {}
      end

      def query(&block)
        validation = Validation.new(request.query)
        validation.instance_exec(&block)
        properties.merge!(validation.properties)
      end

      def body(&block)
        validation = Validation.new(request.body)
        validation.instance_exec(&block)
        properties.merge!(validation.properties)
      end

      attr_reader :request, :properties

      class Validation
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
    end

    Request = Struct.new(:method, :uri, :headers, :query, :body, keyword_init: true)
    Route = Struct.new(:Route, :method, :matcher, :handler, keyword_init: true)

    class ValidationError < StandardError; end
  end
end
