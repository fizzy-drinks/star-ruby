module Star
  class Router
    def initialize(app)
      @app = app
      @routes = []
    end

    attr_reader :app, :routes

    def handle(request)
      request => { uri:, method: }

      res = Response.new(headers: {"Content-Type" => "application/json"}, status: 200)
      route = routes.find { |route| uri === route.matcher && route.method.to_s.upcase == method }
      unless route
        res.status = 404
        return res
      end

      res.body = app.instance_exec(request, &route.handler)
      res
    end

    Request = Struct.new(:Request, :method, :query, :uri, :body, :headers, keyword_init: true)
    Response = Struct.new(:Response, :status, :body, :headers, keyword_init: true)
    Route = Struct.new(:Route, :method, :matcher, :handler, keyword_init: true)
  end
end
