require_relative "base"
require "json"

module Star
  module DatabaseAdapter
    class Json < Base
      def initialize
        @db_name = "./db.json"
      end

      attr_accessor :db_name

      def find(collection, matcher)
        data = read_data
        data[collection.to_s] ||= []
        data[collection.to_s].find { |i| matcher.all? { |k, v| i[k.to_s] == v } }
      end

      def where(collection, matcher)
        data = read_data
        data[collection.to_s] ||= []
        data[collection.to_s].filter { |i| matcher.all? { |k, v| v.nil? || i[k.to_s] == v } }
      end

      def insert(collection, item)
        data = read_data
        data[collection.to_s] ||= []
        data[collection.to_s] << item

        write_data data

        item
      end

      def update(collection, matcher, update)
        data = read_data
        data[collection.to_s] ||= []
        data[collection.to_s].map! { |i|
          next i unless matcher.all? { |k, v| i[k.to_s] == v }

          i.merge(update)
        }

        write_data data
      end

      def delete(collection, matcher)
        data = read_data
        data[collection.to_s] ||= []
        data[collection.to_s].filter! { |i| !matcher.all? { |k, v| i[k.to_s] == v } }

        write_data data
      end

      private

      def read_data
        content = File.exist?(db_name) ? File.read(db_name) : ""
        data = JSON.parse content unless content.empty?
        data || {}
      end

      def write_data(data)
        File.write(db_name, data.to_json)
      end
    end
  end
end
