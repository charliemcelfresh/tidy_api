class AssetHeaders
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    response = @app.call(env)
    response[1]["Content-Type"] = "application/json"
    response
  end
end

require './main'
use AssetHeaders
run Sinatra::Application
