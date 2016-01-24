require "http/server"
require "./cookies"
require "./encoder"
require "json"

class HTTP::Server::Context
  property! session
end

module Session
  class Session(T)
    JSON.mapping({_v: T})

    forward_missing_to _v

    def initialize
      @_v = T.new
    end

    def store(value : T)
      self._v = value
    end
  end

  class Handler(T) < HTTP::Handler
    def initialize(@session_key = "cr.session", secret = raise("Please set a secret"))
      @encoder = Encoder.new(secret)
    end

    def call(context)
      context.session = load_session(context.request.cookies) || Session(T).new
      checksum = @encoder.hex_digest(context.session.to_json)
      call_next(context)
      store_session(context.response, context.session, checksum)
    end

    private def load_session(cookies)
      if cookie = cookies[@session_key]?
        begin
          Session(T).from_json(@encoder.decode(cookie.value))
        rescue Encoder::BadData
          Session(T).new
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
