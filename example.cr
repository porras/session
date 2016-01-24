require "http/server"
require "./src/session/handler"

class App < HTTP::Handler
  def call(context)
    if context.request.query_params["reset"]?
      context.session["time"] = Time.now.inspect
    end
    context.response.print "#{context.session.inspect}\n"
  end
end

app = App.new

p app

server = HTTP::Server.new("0.0.0.0", "3000", [
  HTTP::LogHandler.new,
  HTTP::ErrorHandler.new,
  Session::Handler.new,
  app,
])

server.listen
