require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'rack/test/json'

set :environment, :test

include Rack::Test::Methods

def app
  Sinatra::Application
end

managers = User.where(role: 0)
drivers = User.where(role: 1)

def get_authorization_header
  "123:client_secret"
end

describe 'GET API' do

  it "should load the home page" do
    get '/', {}, { 'Content-Type' => 'application/json' }

    expect(last_response.body).to eq("index")
    expect(last_response).to be_ok
  end

  it "should not load the tasks page" do
    get '/api/v1/tasks', {}, { 'Content-Type' => 'application/json' }

    expect(last_response).to_not be_ok
    expect(last_response.status).to eq 401
  end

  it "should load tasks page" do
    get '/api/v1/tasks', {}, { 'HTTP_AUTHORIZATION' => get_authorization_header, 'Content-Type' => 'application/json' }

    expect(last_response).to be_ok
    expect(last_response).to be_json
    expect(last_response.as_json[0]['delivery']).to be == 'New York'
  end

  it "should load nearby tasks" do
    get '/api/v1/tasks', { lat: 40.6643, lng: 73.9385 }, { 'HTTP_AUTHORIZATION' => get_authorization_header, 'Content-Type' => 'application/json' }

    expect(last_response).to be_ok
    expect(last_response).to be_json
    expect(last_response.as_json.length).to be == 2
  end
end

describe 'POST API' do

  it "manager should create the task" do
    jack = managers[0]
    post '/api/v1/tasks', { lat: 39.6643, lng: 73.9001, delivery: "Somewhere" }, { 'HTTP_AUTHORIZATION' => get_authorization_header, 'Content-Type' => 'application/json' }

    Task.count.should == 7
    created = Task.find_by(delivery: "Somewhere")
    expect(created).to_not eq(nil)
    created.destroy
    expect(last_response.status).to eq 201
  end

  it "manager should not create the task without params" do
    post '/api/v1/tasks', {}, { 'HTTP_AUTHORIZATION' => get_authorization_header, 'Content-Type' => 'application/json' }

    expect(last_response.status).to eq 400
  end

end

