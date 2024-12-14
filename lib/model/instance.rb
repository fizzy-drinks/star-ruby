module Star
  class Model
    class Instance
      def initialize(model, data)
        @model = model
        @data = model.schema.map(data)
      end

      attr_reader :data, :model

      def method_missing(method) = data[method.to_s]

      def respond_to_missing?(method, *)
        model.schema.prop?(method)
      end

      def deconstruct_keys(*)
        data.map { |k, v| [k.to_sym, v] }.to_h
      end

      def to_json(*)
        data.to_json(*)
      end
    end
  end
end
