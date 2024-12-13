require_relative "runtime"

module Star
  module Builders
    class AppBuilder
      def app name = nil
        @app ||= App.new(name) if name
        @app
      end

      def model(name, &block)
        app.models << ModelBuilder.build(app, name, &block) if name && block
        app.models
      end

      def method_missing(method) = method

      def respond_to_missing? = true

      def self.build &block
        builder = new
        builder.instance_eval(&block)
        builder.app
      end
    end

    class ModelBuilder
      def initialize(app, name)
        @model = Model.new(app, name)
      end

      attr_reader :model

      def method_missing property_name, &block
        model.schema.add_property(PropertyBuilder.build(property_name, &block))
      end

      def respond_to_missing? = true

      def self.build(app, name, &block)
        builder = new(app, name)
        builder.instance_eval(&block)
        builder.model
      end
    end

    class PropertyBuilder
      def initialize(name)
        @property = Model::Schema::Property.new(name:)
      end

      attr_reader :property

      def required(*)
        @property.required = true
      end

      def string(*, &block)
        @property.datatype = :string
        @property.default_proc = block if block
      end

      def date(*, &block)
        @property.datatype = :date
        @property.default_proc = block if block
      end

      def self.build name, &block
        builder = new(name)
        builder.instance_eval(&block)
        builder.property
      end
    end
  end

  AppBuilder = Builders::AppBuilder
end
