require "./spec_helper"

describe Session::Encoder do
  it "encodes and decodes" do
    data = {"hello" => ["world", Time.now.to_s]}
    message = data.to_json
    encoder = Session::Encoder.new(rand(1_000_000_000).to_s)
    encoded = encoder.encode(message)
    decoded = encoder.decode(encoded)

    data.class.from_json(decoded).should eq(data)
  end

  it "can't be manipulated" do
    data = {"hello" => ["world", Time.now.to_s]}
    message = data.to_json
    encoder = Session::Encoder.new(rand(1_000_000_000).to_s)
    encoded = encoder.encode(message)

    # this attempt at manipulation is coupled with the implementation!
    original_message, signature = encoded.split("--")
    manipulated = Base64.encode(Base64.decode_string(original_message).gsub("hello", "hacko")) + "--" + signature
    expect_raises Session::Encoder::BadData do
      encoder.decode(manipulated)
    end
  end
end
