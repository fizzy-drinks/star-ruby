require "time"
require_relative "../model"

module Star
  module Builders
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
        builder.model.prepare!
        builder.model
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
          @property.datatype = String
          @property.default_proc = block if block
        end

        def date(*, &block)
          @property.datatype = DateTime
          @property.default_proc = block if block
        end

        def self.build name, &block
          builder = new(name)
          builder.instance_eval(&block)
          builder.property
        end
      end
    end
  end
end
