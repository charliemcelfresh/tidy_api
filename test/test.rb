# test.rb
require File.expand_path '../test_helper.rb', __FILE__

class MyTest < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_hello_world
    get '/api/products'
    assert last_response.ok?
    assert_kind_of Array, JSON.parse(last_response.body)
  end

end