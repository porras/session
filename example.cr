require "http/server"
require "./src/session/handler"

class App < HTTP::Handler
  def call(context)
    if context.request.query_params["reset"]?
      context.session["time"] = Time.now.second
    end
    context.response.print "#{context.session.inspect}\n"
  end
end

server = HTTP::Server.new("0.0.0.0", "3000", [
  HTTP::LogHandler.new,
  HTTP::ErrorHandler.new,
  Session::Handler(Hash(String, Int32)).new(secret: "wadus"),
  App.new,
])

server.listen
