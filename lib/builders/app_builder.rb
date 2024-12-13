require_relative "model_builder"
require_relative "../app"

module Star
  module Builders
    class AppBuilder
      def app name = nil
        @app ||= App.new(name) if name
        @app
      end

      def db adapter
        app.define_singleton_method(:db) { adapter.new }
      end

      def model(name, &block)
        app.models << ModelBuilder.build(app, name, &block) if name && block
        app.models
      end

      def main(&block)
        app.define_singleton_method(:main, &block)
      end

      def method_missing(method)
        super if block_given?

        method
      end

      def respond_to_missing? = true

      def self.build &block
        builder = new
        builder.instance_eval(&block)
        builder.app
      end
    end
  end
end
