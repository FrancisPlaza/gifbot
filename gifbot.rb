#ruby

require 'bundler/setup'
require 'json'
require 'net/http'
require 'sinatra'

SLACK_TOKEN="RwxeTfyhVQ059T0rUzVLNhSs"
GIPHY_KEY="dc6zaTOxFJmzC"
# TRIGGER_WORD="#"
IMAGE_STYLE="fixed_height" # or "fixed_width" or "original"

post "/gif" do
  puts request.inspect
  puts request["token"]
  return 401 unless request["token"] == SLACK_TOKEN
  q = request["text"]
  # return 200 unless q.start_with? TRIGGER_WORD
  q = URI::encode q
  url = "http://api.giphy.com/v1/gifs/search?q=#{q}&api_key=#{GIPHY_KEY}&limit=50"
  $stderr.puts "querying giphy: #{url}"
  resp = Net::HTTP.get_response(URI.parse(url))
  buffer = resp.body
  result = JSON.parse(buffer)
  images = result["data"].map {|item| item["images"]}
  # filter out images > 2MB(?) because Slack
  images.select! {|image| image["original"]["size"].to_i < 1<<21}
  if images.empty?
    text = ":cry:"
  else
    selected = images[rand images.size]
    text = "<" + selected[IMAGE_STYLE]["url"] + ">"
  end
  reply = {text: text}
  $stderr.puts reply
  return JSON.generate(reply)
end
