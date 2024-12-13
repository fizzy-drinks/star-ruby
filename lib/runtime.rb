require "json"

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

  class App
    def initialize name
      @name = name
      @models = ModelCollection.new
    end

    attr_reader :name, :models

    def migrate!
      {tables: models.map { |model| [model.name, []] }.to_h}
    end

    def to_json(*)
      {name:, models:}.to_json(*)
    end

    class ModelCollection < Array
      def method_missing name
        find { |model| model.name == name }
      end

      def respond_to_missing? = true
    end
  end
end
