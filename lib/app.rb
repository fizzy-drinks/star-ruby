require "json"
require "socket"
require "time"
require_relative "router"

module Star
  class App
    def initialize name
      @name = name
      @models = ModelCollection.new
      @router = Router.new(self)
    end

    attr_reader :name, :models, :db, :router

    def migrate!
      {tables: models.map { |model| [model.name, []] }.to_h}
    end

    def serve!
      server = TCPServer.new(3000)
      while (session = server.accept)
        method, uri, * = session.gets.split(" ")

        headers = {}
        until (header_line = session.gets.strip) == ""
          header, content = header_line.split(":").map(&:strip)
          headers[header.downcase] = content
        end

        uri, query = uri.split("?")
        query = query.to_s.split("&").map { |pair| pair.split("=") }.to_h
        request = Router::Request.new(method:, uri:, query:, headers:)

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

        session.puts [
          "HTTP/1.1 200",
          *response.headers.map { |k, v| "#{k}: #{v}" }.join("\n"),
          "",
          response.body
        ].join("\n")
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
