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

def get_manager_header
  "123:client_secret"
end

def get_driver_header
  "768:client_secret"
end

describe 'GET API' do

  it "should load the home page" do
    get '/', {}, { 'Content-Type' => 'application/json' }

    expect(last_response.body).to eq("index")
    expect(last_response).to be_ok
  end

  it "should not load the tasks page" do
    get '/api/v1/driver/tasks', {}, { 'Content-Type' => 'application/json' }

    expect(last_response).to_not be_ok
    expect(last_response.status).to eq 401
  end

  it "should load tasks page" do
    get '/api/v1/driver/tasks', {}, { 'HTTP_AUTHORIZATION' => get_manager_header, 'Content-Type' => 'application/json' }

    expect(last_response).to be_ok
    expect(last_response).to be_json
    Task.count.should == 6
  end

  it "should load nearby tasks" do
    get '/api/v1/driver/tasks', { lat: 40.6643, lng: 73.9385 }, { 'HTTP_AUTHORIZATION' => get_driver_header, 'Content-Type' => 'application/json' }

    expect(last_response).to be_ok
    expect(last_response).to be_json
    expect(last_response.as_json.length).to be == 2
  end
end

describe 'POST API' do

  it "manager should create the task" do
    auth_header = get_manager_header.split(':')
    token = auth_header[0]
    puts "MANAGER ROLE: #{User.find_by(token: token).role}"

    post '/api/v1/manager/tasks', { lat: 39.6643, lng: 73.9001, delivery: "Somewhere" }, { 'HTTP_AUTHORIZATION' => get_manager_header, 'Content-Type' => 'application/json' }

    Task.count.should == 7
    created = Task.find_by(delivery: "Somewhere")
    expect(created).to_not eq(nil)
    created.destroy
    expect(last_response.status).to eq 201
  end

  it "driver should not create the task" do
    auth_header = get_driver_header.split(':')
    token = auth_header[0]
    puts "DRIVER ROLE: #{User.find_by(token: token).role}"

    post '/api/v1/manager/tasks', { lat: 39.6643, lng: 73.9001, delivery: "Somewhere" }, { 'HTTP_AUTHORIZATION' => get_driver_header, 'Content-Type' => 'application/json' }

    Task.count.should == 6
    expect(last_response.status).to eq 401
  end

  it "manager should delete the task" do
    id = Task.last.id.to_s
    delete "/api/v1/manager/task/#{id}", {}, { 'HTTP_AUTHORIZATION' => get_manager_header, 'Content-Type' => 'application/json' }

    Task.count.should == 5
    Task.create(delivery: "New York", location: [40.6643, 73.9385], state: 0)
    expect(last_response.status).to eq 204
  end

  it "manager should not create the task without params" do
    post '/api/v1/manager/tasks', {}, { 'HTTP_AUTHORIZATION' => get_manager_header, 'Content-Type' => 'application/json' }

    expect(last_response.status).to eq 400
  end

  it "driver should assign task" do
    id = Task.last.id.to_s
    put "/api/v1/driver/task/#{id}", { state: 1 }, { 'HTTP_AUTHORIZATION' => get_driver_header, 'Content-Type' => 'application/json' }

    created = Task.find(id)
    created.state.should == 1
    created.update_attributes(state: 0)
    expect(last_response.status).to eq 201
  end

  it "driver should not assign task with wrong state" do
    id = Task.last.id.to_s
    put "/api/v1/driver/task/#{id}", { state: 3 }, { 'HTTP_AUTHORIZATION' => get_driver_header, 'Content-Type' => 'application/json' }

    created = Task.find(id)
    created.state.should == 0
    expect(last_response.status).to eq 500
  end

  it "driver should done task" do
    id = Task.last.id.to_s
    put "/api/v1/driver/task/#{id}", { state: 2 }, { 'HTTP_AUTHORIZATION' => get_driver_header, 'Content-Type' => 'application/json' }

    expect(last_response.status).to eq 201
  end

end

