require_relative "use_context"

module Star
  module Routing
    class Router
      def initialize(app)
        @app = app
        @routes = []
      end

      attr_reader :app, :routes

      def route_match?(uri, matcher)
        re = %r{^#{matcher.gsub(/\{[^{}\/]+\}/, "[^/]+")}/?$}
        uri = uri.sub(%r{^/?(.*)/?$}, '\1')
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

        route.before.compact.each do |block|
          res.instance_exec(request, &block)
        end

        res.body = res.instance_exec(request, &route.handler)
        res
      rescue Util::Validation::ValidationError => e
        res.body = {message: e.message}.to_json
        res.status = 400
        res
      end
    end

    Response = Struct.new(:app, :request, :status, :body, :headers, keyword_init: true) do
      def use(&block)
        using ||= UseContext.new(request)
        using.instance_exec(&block) if block
        using.properties.each do |key, value|
          define_singleton_method(key.to_sym) { value }
        end
      end
    end

    Request = Struct.new(:method, :uri, :headers, :query, :body, keyword_init: true)
    Route = Struct.new(:method, :matcher, :handler, :before, keyword_init: true)
  end
end
