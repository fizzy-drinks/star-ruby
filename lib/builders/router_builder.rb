require_relative "../routing/router"

module Star
  module Builders
    class RouterBuilder
      def initialize(app)
        @router = app.router
      end

      attr_reader :router, :scope_path

      methods = %i[get post put patch delete options]
      methods.each do |method|
        define_method(method) do |matcher = "/", &handler|
          full_scope = [*scope_path, matcher]
          scoped_matcher = full_scope.map { |seg| seg.to_s.sub(%r{^/?(.*)/?$}, '\1') }.reject(&:empty?).join("/")
          router.routes << Routing::Route.new(method:, matcher: scoped_matcher, handler:, before:)
        end
      end

      def before(&block)
        @before = block if block
        @before
      end

      def scope path, &block
        @scope_path ||= []
        @scope_path << path
        instance_exec(&block)
        @scope_path.pop
      end

      def method_missing method, *, &block
        scope method, *, &block
      end

      def respond_to_missing? = true

      def self.build app, &block
        builder = new(app)
        builder.instance_exec(&block)
        builder.router
      end
    end
  end
end
