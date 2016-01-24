require "http/server"
require "./cookies"
require "./encoder"
require "json"

class HTTP::Server::Context
  property! session
end

module Session
  class Handler(T) < HTTP::Handler
    def initialize(@session_key = "cr.session", secret = raise("Please set a secret"))
      @encoder = Encoder.new(secret)
    end

    def call(context)
      context.session = load_session(context.request.cookies) || T.new
      checksum = @encoder.hex_digest(context.session.to_json)
      call_next(context)
      store_session(context.response, context.session, checksum)
    end

    private def load_session(cookies)
      if cookie = cookies[@session_key]?
        begin
          T.from_json(@encoder.decode(cookie.value))
        rescue Encoder::BadData
          T.new
        end
      end
    end

    private def store_session(response, session, checksum)
      data = session.to_json
      return if checksum == @encoder.hex_digest(data)
      response.set_cookie(@session_key, @encoder.encode(data))
    end
  end
end
