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

  client_secret = 'client_secret'

  data = request.path
  data = "#{data}?#{request.query_string}" if request.query_string.present?

  if ['POST', 'PUT', 'PATCH'].include? request.request_method
    request.body.rewind
    data += request.body.read
  end

  computed_signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), client_secret, data)

  if computed_signature == signature
    pass
  else
    halt 403
  end

end

get '/' do
  "index"
end

get '/users' do
  content_type :json
  users = User.all
  users.to_json
end

get '/tasks' do
  content_type :json
  tasks = Task.order_by(created_at: 'desc')
  tasks.to_json
end
