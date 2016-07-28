require 'rubygems'
require 'bundler'

Bundler.require(:default)
require './user'
require './task'

configure do
  Mongoid.load!("./database.yml", :development)
end

before do
  # Pass on index route
  pass if [nil].include? request.path_info.split('/')[1]

  # Pull out the authorization header
  if env['HTTP_AUTHORIZATION'] && env['HTTP_AUTHORIZATION'].split(':').length == 2
    auth_header = env['HTTP_AUTHORIZATION'].split(':')
  else
    halt 401
  end

  token = auth_header[0]
  signature = auth_header[1]

  user = User.find_by(token: token)

  halt 403 if user.nil?

  if 'client_secret' == signature
    pass
  else
    halt 403
  end

end

get '/' do
  "index"
end

namespace '/api/v1' do

  before do
    content_type 'application/json'
  end

  namespace '/manager' do

    get '/users' do
      users = User.order_by(created_at: 'desc')
      users.to_json
    end

    get '/tasks' do
      Task.order_by(created_at: 'desc')
      tasks.to_json
    end

    post '/tasks' do
      auth_header = env['HTTP_AUTHORIZATION'].split(':')
      token = auth_header[0]
      if User.find_by(token: token).role == 1
        return [401, { message: "User is not manager" }.to_json]
      end
      delivery = params[:delivery]
      location = [params[:lat].to_f, params[:lng].to_f]

      unless [location, delivery].all?
        halt 400, { message: "location and delivery params cannot be empty" }.to_json
      end

      task = Task.new(delivery: delivery, location: location)
      if task.save
        [201, task.to_json]
      else
        [500, { message: "Failed to save task" }.to_json]
      end
    end

    delete '/task/:id' do |id|
      auth_header = env['HTTP_AUTHORIZATION'].split(':')
      token = auth_header[0]
      if User.find_by(token: token).role == 1
        return [401, { message: "User is not manager" }.to_json]
      end
      task = Task.where(id: id).first
      if task
        task.destroy
        status 204
      else
        status 500
      end
    end
  end

  namespace '/driver' do

    get '/tasks' do
      tasks = if params.present?
        lat = params[:lat].to_f
        lng = params[:lng].to_f
        Task.geo_near([lat, lng]).max_distance(5)
      else
        Task.order_by(created_at: 'desc')
      end
      tasks.to_json
    end

    put '/task/:id' do
      auth_header = env['HTTP_AUTHORIZATION'].split(':')
      token = auth_header[0]
      if User.find_by(token: token).role == 0
        return [401, { message: "User is not driver" }.to_json]
      end
      task = Task.find(params[:id])
      state = params['state'].to_i

      if [1, 2].include? state
        task.update_attributes(state: state)
        [201, task.to_json]
      else
        [500, { message: "Failed to save task" }.to_json]
      end
    end
  end

end
