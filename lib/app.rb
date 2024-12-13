module Star
  class App
    def initialize name
      @name = name
      @models = ModelCollection.new
    end

    attr_reader :name, :models, :db

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
