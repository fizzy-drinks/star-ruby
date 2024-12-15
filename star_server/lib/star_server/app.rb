require "json"
require "socket"
require "time"
require_relative "routing/router"

module Star
  class App
    def initialize name
      @name = name
      @models = ModelCollection.new
      @router = Routing::Router.new(self)
    end

    attr_reader :name, :models, :db, :router

    def serve!
      server = TCPServer.new(3000)
      while (session = server.accept)
        method, uri, * = session.gets.split(" ")

        headers = {}
        until (header_line = session.gets.strip) == ""
          header, *content = header_line.split(":").map(&:strip)
          headers[header.downcase] = content.join(":")
        end

        uri, query = uri.split("?")
        query = query.to_s.split("&").each_with_object({}) { |pair, obj|
          key, value = pair.split("=")
          obj[key] = value
        }
        request = Routing::Request.new(method:, uri:, query:, headers:)

        content_length = headers["content-length"].to_i
        if content_length > 0
          body = ""
          session.each(content_length) do |b|
            body += b
            break if body.length == content_length
          end

          request.body = JSON.parse body
        end
        response = router.handle(request)
        if response.body.is_a?(Hash) || response.body.is_a?(Array)
          response.body = response.body.to_json
        end

        session.puts [
          "HTTP/1.1 #{response.status}",
          *response.headers.map { |k, v| "#{k}: #{v}" },
          "Content-Length: #{response.body.to_s.length}",
          "",
          response.body
        ].join("\r\n")
        session.close
      end
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
