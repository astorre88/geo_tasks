require 'mongoid'
require 'mongoid/geospatial'
require './user'
require './task'

Mongoid.load!("./database.yml", :development)

Mongoid.logger = nil
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
  ["New York", [40.6643, 73.9385]],
  ["Los Angeles", [34.0194, 118.4108]],
  ["Chicago", [41.8376, 87.6818]],
  ["Houston", [29.7805, 95.3863]],
  ["Philadelphia", [40.0094, 75.1333]],
  ["Phoenix", [33.5722, 112.0880]]
]

tasks.each do |task|
  Task.create(delivery: task[0], location: task[1], state: task[2])
end

Task.create_indexes
