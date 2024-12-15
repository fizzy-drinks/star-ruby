require "time"
require_relative "../model"
require_relative "property_builder"

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
    end
  end
end
