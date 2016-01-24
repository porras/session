# Session

Session is a [Crystal](http://crystal-lang.org/)'s `HTTP::Handler` that implement's cookie based sessions. It can be combined with other bultin or custom handlers, as well as with other Crystal libraries that implement `HTTP::Handler`s such as [kemal](https://github.com/sdogruyol/kemal).

It takes a lot of inspiration from [`Rack::Session::Cookie`](https://github.com/rack/rack/blob/master/lib/rack/session/cookie.rb), but it's much smaller, simpler, and obviously less feature-rich. Also less widespread and tested, but you can help with that!

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  session:
    github: porras/session
```

## Usage

`Session::Handler` is a generic class, that is, requires a type to be passed when instantiating it. This type is the data structure where your session data will be stored. This type has to be:

* Serializable to JSON, either because it's a bultin type that is, or via `JSON.mapping` if it's a custom type
* Initializable without parameters

`Hash(String, String)` makes a sensible yet simple and flexible example.

Once you instantiate the handler passing the underlying type and the wanted options (see below), and you put it in the HTTP handlers chain, all downstream handlers will have a `context.session` available to read and update.

### Options

* **`secret`** (mandatory): the content of the session cookie are **not encrypted** but *signed*. That is, a user could read the contents (provided that they know the algorithim, which is available in the source code, and pretty simple), but not change it (because the signature wouldn't match). This secret is used for that.
* **`session_key`** (defaults to `"cr.session"`): name of the cookie were the data will be stored.

### Raw HTTP::Handler example

```crystal
require "http/server"
require "session/handler"

session_handler = Session::Handler(Hash(String, String)).new(secret: "SUPERSECRET")

server = HTTP::Server.new("0.0.0.0", "3000", [
  HTTP::LogHandler.new,
  HTTP::ErrorHandler.new,
  session_handler,
]) do |context|
  # context.session is a Session::Handler(Hash(String, String)), behaves like a Hash(String, String)
  context.session["first_seen_at"] ||= Time.now.to_s
  context.response.print "You came first at #{context.session["first_seen_at"]}"
end

server.listen
```

### Kemal example

TODO

### Security

TODO

## Contributing

1. Fork it ( https://github.com/porras/session/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [porras](https://github.com/porras) Sergio Gil - creator, maintainer
