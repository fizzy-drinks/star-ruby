require "sqlite3"
require "pry"

module Star
  module DatabaseAdapter
    class Sqlite
      def find(collection, matcher)
        valid_matchers = matcher.filter { |_k, v| !v.nil? }

        results = db.execute "select * from #{collection} #{where_clause(valid_matchers)} ;"

        col_names = columns collection
        results.empty? ? nil : col_names.zip(results[0]).to_h
      end

      def where(collection, matcher)
        valid_matchers = matcher.filter { |_k, v| !v.nil? }
        results = db.execute "select * from #{collection} #{where_clause(valid_matchers)} ;"

        col_names = columns collection
        results.map { |row| col_names.zip(row).to_h }
      end

      def insert(collection, item)
        col_names = columns collection
        sorted_values = col_names.map { |col| item.data[col.to_sym].to_json }
        db.execute "insert into #{collection} values (#{sorted_values.join(",")})"
      end

      def update(collection, matcher, update)
        valid_matchers = matcher.filter { |_k, v| !v.nil? }
        values = update.map { |k, v| [k, v.to_json].join(" = ") }.join(",")

        db.execute "update #{collection} set #{values} #{where_clause(valid_matchers)}"
        where(collection, matcher)
      end

      def delete(collection, matcher)
        valid_matchers = matcher.filter { |_k, v| !v.nil? }
        db.execute "delete from #{collection} #{where_clause(valid_matchers)}"
      end

      def prepare(model)
        columns = model.schema.properties.values.map { |prop| [prop.name, prop.datatype] }
        create_table_if_not_exists(model.name, columns)
      end

      private

      def db = SQLite3::Database.new("db.sqlite3")

      def create_table_if_not_exists(table_name, columns)
        cols = columns.map { |name, type| "#{name} #{type}" }
        db.execute <<-SQL
          create table if not exists #{table_name} (
            #{cols.join(",")}
          )
        SQL
      end

      def columns collection
        db.execute("pragma table_info(#{collection})").map { _1[1] }
      end

      def where_clause(matchers)
        matchers.empty? ? "" : "where #{matchers.map { |k, v| "#{k} = #{v.to_json}" }.join(" and ")}"
      end
    end
  end
end
