require "openssl/hmac"
require "base64"

module Session
  class Encoder
    class BadData < Exception
    end

    def initialize(@secret : String)
    end

    def encode(data : String)
      Base64.encode "#{Base64.encode(data)}--#{generate_signature(data)}"
    end

    def decode(data : String)
      data, signature = Base64.decode_string(data).split("--")
      Base64.decode_string(data).tap do |data|
        raise BadData.new("Signature does not match") unless generate_signature(data) == signature
      end
    end

    private def generate_signature(data)
      OpenSSL::HMAC.hexdigest(:sha1, @secret, data)
    end
  end
end
