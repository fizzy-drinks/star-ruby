require_relative "model/instance"
require_relative "model/schema"

module Star
  class Model
    def initialize(app, name)
      @app = app
      @name = name
      @schema = Schema.new
    end

    attr_reader :app, :name, :schema

    def find(**kwargs)
      found = app.db.find(name, kwargs)
      found && Instance.new(self, found)
    end

    def where(**kwargs)
      app.db.where(name, kwargs) do |item|
        Instance.new(self, item)
      end
    end

    def create(**kwargs)
      data = schema.properties.each_with_object({}) do |(name, prop), obj|
        obj[name.to_s] = kwargs[name] || prop.default_proc&.call || nil
      end

      Instance.new(self, data)
        .tap do
          app.db.insert(name, data)
        end
    end

    def update(match:, update:)
      app.db.update(name, match, update)
    end

    def delete(**kwargs)
      app.db.delete(name, kwargs)
    end

    def prepare!
      app.db.prepare(self)
    end

    def to_json(*)
      {name:, schema:}.to_json(*)
    end
  end
end
