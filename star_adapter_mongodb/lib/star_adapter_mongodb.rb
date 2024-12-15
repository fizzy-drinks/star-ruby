require "mongo"

module Star
  module DatabaseAdapter
    class MongoDB < Base
      def find(*)
        where(*).first
      end

      def where(collection_name, matcher)
        collection = db[collection_name.to_sym]

        valid_matchers = matcher.filter { |_k, v| !v.nil? }
        collection.find(valid_matchers).to_a
      end

      def insert(collection_name, item)
        collection = db[collection_name.to_sym]
        collection.insert_one(item)
      end

      def update(collection_name, matcher, update)
        collection = db[collection_name.to_sym]
        collection.update_one(matcher, {"$set" => update})
        where(collection_name, matcher)
      end

      def delete(collection_name, matcher)
        collection = db[collection_name.to_sym]
        collection.delete_one(matcher)
        where(collection_name, matcher)
      end

      private

      def db
        @db ||= Mongo::Client.new(ENV["MONGO_URI"], database: ENV["MONGO_DATABASE"])
      end
    end
  end
end
