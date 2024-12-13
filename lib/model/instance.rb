module Star
  class Model
    class Instance
      def initialize(model, data)
        @model = model
        @data = model.schema.map(data)
      end

      attr_reader :data

      def to_json(*)
        data.to_json(*)
      end
    end
  end
end
