require "http/server"
require "./src/session"

# Every request increments the visits counter
# Requests with the parameter "store" store that value
class App < HTTP::Handler
  def call(context)
    if context.request.query_params["store"]?
      context.session.content = context.request.query_params["store"]
    end
    context.session.visits += 1
    context.response.print "#{context.session.inspect}\n"
  end
end

class MySession
  JSON.mapping({
    content: {type: String, key: "c", nilable: true},
    visits:  {type: Int32, key: "v"},
  })

  def initialize
    @visits = 0
  end
end

server = HTTP::Server.new("0.0.0.0", "3000", [
  HTTP::LogHandler.new,
  HTTP::ErrorHandler.new,
  Session::Handler(MySession).new(secret: "wadus"),
  App.new,
])

server.listen
