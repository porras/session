require "./spec_helper"

module HandlerSpecHelper
  def self.request(handler, headers = HTTP::Headers.new, &next_handler : HTTP::Server::Context -> Void)
    io = MemoryIO.new
    request = HTTP::Request.new("GET", "/", headers)
    response = HTTP::Server::Response.new(io)
    context = HTTP::Server::Context.new(request, response)

    handler.next = next_handler
    handler.call(context)
    response.close

    response
  end
end

describe Session::Handler do
  it "keeps session between requests" do
    handler = Session::Handler(Hash(String, String)).new(secret: "wadus")

    response = HandlerSpecHelper.request(handler) do |ctx|
      ctx.session["hello"] = "world"
    end

    cookie = response.headers["Set-Cookie"]
    headers = HTTP::Headers.new
    headers["Cookie"] = cookie
    hello = nil
    response = HandlerSpecHelper.request(handler, headers: headers) do |ctx|
      hello = ctx.session["hello"]?
      ctx.session["hello"] = "second request"
    end

    hello.should eq("world")

    cookie = response.headers["Set-Cookie"]
    headers = HTTP::Headers.new
    headers["Cookie"] = cookie
    response = HandlerSpecHelper.request(handler, headers: headers) do |ctx|
      hello = ctx.session["hello"]?
    end

    hello.should eq("second request")
    # and doesn't set the unchanged session again
    response.headers["Set-Cookie"]?.should be_nil
  end

  it "starts new sessions" do
    handler = Session::Handler(Hash(String, String)).new(secret: "wadus")

    response = HandlerSpecHelper.request(handler) do |ctx|
      ctx.session["hello"] = "world"
    end

    hello = nil
    HandlerSpecHelper.request(handler) do |ctx|
      hello = ctx.session["hello"]?
    end

    hello.should be_nil
  end
end
