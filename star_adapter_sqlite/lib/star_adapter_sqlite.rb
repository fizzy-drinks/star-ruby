require "star_server/database_adapter/base"
require "sqlite3"

module Star
  module DatabaseAdapter
    class Sqlite < Base
      warn "WARNING: You should probably work with a real SQLite ORM!"
      warn "         This is just my attempt at demonstrating how a SQL adapter for Star would work."
      warn ""
      warn "         In any case, contributions are welcome."

      def find(collection, matcher)
        valid_matchers = matcher.filter { |_k, v| !v.nil? }

        results = db.execute "select * from #{collection} #{where_clause(valid_matchers)} ;"

        col_names = columns(collection).map { _1[1] }
        results.empty? ? nil : col_names.zip(results[0]).to_h
      end

      def where(collection, matcher)
        valid_matchers = matcher.filter { |_k, v| !v.nil? }
        results = db.execute "select * from #{collection} #{where_clause(valid_matchers)} ;"

        col_names = columns(collection).map { _1[1] }
        results.map { |row| col_names.zip(row).to_h }
      end

      def insert(collection, item)
        col_names = columns(collection).map { _1[1] }
        sorted_values = col_names.map { |col| item.data[col.to_s].to_json }
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
        schema_cols = model.schema.properties.values.map { |prop| [prop.name, prop.datatype, prop.default_proc] }
        create_table_if_not_exists(model.name, schema_cols)

        existing_cols = columns(model.name)
        missing_cols = schema_cols.filter { |(name_a)| existing_cols.none? { |(_i, name_b)| name_a.to_s == name_b.to_s } }

        missing_cols.each do |(name, type, default)|
          puts "Migrations: added #{model.name}.#{name} (#{type})"
          default = "default #{default.call.to_json}" if default
          db.execute "alter table #{model.name} add column #{name} #{type} #{default}"
        end
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

      def columns(collection)
        db.execute("pragma table_info(#{collection})")
      end

      def where_clause(matchers)
        matchers.empty? ? "" : "where #{matchers.map { |k, v| "#{k} = #{v.to_json}" }.join(" and ")}"
      end
    end
  end
end
