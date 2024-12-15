require_relative "../routing/router"

module Star
  module Builders
    class RouterBuilder
      def initialize(app)
        @router = app.router
        @scope_path = []
        @before = [nil]
      end

      attr_reader :router, :scope_path

      methods = %i[get post put patch delete options]
      methods.each do |method|
        define_method(method) do |matcher = "/", &handler|
          full_scope = [*scope_path, matcher]
          scoped_matcher = full_scope.map { |seg| seg.to_s.sub(%r{^/?(.*)/?$}, '\1') }.reject(&:empty?).join("/")
          router.routes << Routing::Route.new(method:, matcher: scoped_matcher, handler:, before: [*before])
        end
      end

      def before(&block)
        @before[-1] = block if block
        @before
      end

      def scope path, &block
        scope_path << path
        before << nil
        instance_exec(&block)
        scope_path.pop
        before.pop
      end

      def use &block
        puts "WARN: #use called outside of route: nothing is going to happen."
        puts "WARN:   if you want to define context values for all child routes, call #before(&block) instead."
        puts "WARN:   if you intend to create a scope named use, call #scope('use', &block) instead."
        puts "        in #{caller_locations(1, 1).first}"
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
