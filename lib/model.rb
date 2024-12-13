module Star
  class Model
    def initialize(app, name)
      @app = app
      @name = name
      @schema = Schema.new
    end

    attr_reader :app, :name, :schema

    def to_json(*)
      {name:, schema:}.to_json(*)
    end

    class Schema
      def initialize
        @properties = {}
      end

      attr_reader :properties

      def add_property(property)
        @properties[property.name] = property
      end

      def to_json(*)
        {properties:}.to_json(*)
      end

      Property = Struct.new(
        :name, :datatype, :required, :default_proc, keyword_init: true
      ) do
        def to_json(*)
          {name:, type: datatype, required:, has_default: !default_proc.nil?}.to_json(*)
        end
      end
    end
  end
end
