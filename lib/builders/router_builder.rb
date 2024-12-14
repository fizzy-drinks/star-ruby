require_relative "../routing/router"

module Star
  module Builders
    class RouterBuilder
      def initialize(app)
        @router = app.router
      end

      attr_reader :router

      methods = %i[get post put patch delete options]
      methods.each do |method|
        define_method(method) do |matcher, &handler|
          router.routes << Routing::Route.new(method:, matcher:, handler:)
        end
      end

      def self.build app, &block
        builder = new(app)
        builder.instance_exec(&block)
        builder.router
      end
    end
  end
end
