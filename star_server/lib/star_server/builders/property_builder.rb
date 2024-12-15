require "date"
require_relative "../util/validation/property"

module Star
  module Builders
    class PropertyBuilder
      def initialize(name)
        @property = Util::Validation::Property.new(name:)
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

      def int(*, &block)
        @property.datatype = Integer
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
