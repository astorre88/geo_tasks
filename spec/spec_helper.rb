require 'rack/test'
require 'rspec'

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../app.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure do |c|
  c.before(:suite) do
    Mongoid::Config.purge!

    users = [
      ["Jack", "123", 0],
      ["John", "456", 0],
      ["Bill", "768", 1],
      ["Austin", "901", 1]
    ]

    users.each do |user|
      User.create(name: user[0], token: user[1], role: user[2])
    end

    tasks = [
      ["New York", [40.6643, 73.9385], 0],
      ["Los Angeles", [34.0194, 118.4108], 0],
      ["Chicago", [41.8376, 87.6818], 0],
      ["Houston", [29.7805, 95.3863], 0],
      ["Philadelphia", [40.0094, 75.1333], 0],
      ["Phoenix", [33.5722, 112.0880], 0]
    ]

    tasks.each do |task|
      Task.create(delivery: task[0], location: task[1], state: task[2])
    end

    Task.create_indexes
  end
  c.include RSpecMixin
end
