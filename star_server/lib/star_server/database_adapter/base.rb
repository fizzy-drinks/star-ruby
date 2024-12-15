module Star
  module DatabaseAdapter
    class Base
      def find(collection, matcher)
        raise NotImplementedError
      end

      def where(collection, matcher)
        raise NotImplementedError
      end

      def insert(collection, item)
        raise NotImplementedError
      end

      def update(collection, matcher, update)
        raise NotImplementedError
      end

      def delete(collection, matcher)
        raise NotImplementedError
      end

      def prepare(model)
      end
    end
  end
end
