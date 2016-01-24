require "http/server"

class HTTP::Server::Response
  def set_cookie(key : String, cookie : HTTP::Cookie)
    headers.add("Set-Cookie", cookie.to_set_cookie_header)
  end

  def set_cookie(key : String, value)
    set_cookie(key, HTTP::Cookie.new(key, value))
  end

  def delete_cookie(key : String)
    set_cookie(key, HTTP::Cookie.new(key, "", expires: Time.new(1970, 1, 1)))
  end
end
