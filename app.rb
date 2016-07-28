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

get '/api/v1/users' do
  content_type :json
  users = User.order_by(created_at: 'desc')
  users.to_json
end

get '/api/v1/tasks' do
  content_type :json
  tasks = if params.present?
    lat = params[:lat].to_f
    lng = params[:lng].to_f
    Task.geo_near([lat, lng]).max_distance(5)
  else
    Task.order_by(created_at: 'desc')
  end
  tasks.to_json
end

post '/api/v1/tasks' do
  content_type :json

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
