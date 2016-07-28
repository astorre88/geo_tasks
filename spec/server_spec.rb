require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'rack/test/json'

set :environment, :test

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe 'GET API' do

  it "should load the home page" do
    get '/', {}, { 'Content-Type' => 'application/json' }

    expect(last_response.body).to eq("index")
    expect(last_response).to be_ok
  end

  it "should not load the tasks page" do
    get '/tasks', {}, { 'Content-Type' => 'application/json' }

    expect(last_response).to_not be_ok
    expect(last_response.status).to eq 401
  end

  it "should load tasks page" do
    uri = '/tasks'
    body = ''
    token = User.find_by(token: '123').token
    client_secret = 'client_secret'
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), client_secret, uri + body)
    header = "#{token}:#{signature}"

    get '/tasks', {}, { 'HTTP_AUTHORIZATION' => header, 'Content-Type' => 'application/json' }

    expect(last_response).to be_ok
    expect(last_response).to be_json
    expect(last_response.as_json[0]['delivery']).to be == 'New York'
  end
end
