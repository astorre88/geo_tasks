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
  ["New York", { lat: 40.6643, lng: 73.9385 }],
  ["Los Angeles", { lat: 34.0194, lng: 118.4108 }],
  ["Chicago", { lat: 41.8376, lng: 87.6818 }],
  ["Houston", { lat: 29.7805, lng: 95.3863 }],
  ["Philadelphia", { lat: 40.0094, lng: 75.1333 }],
  ["Phoenix", { lat: 33.5722, lng: 112.0880 }]
]

tasks.each do |task|
  Task.create(delivery: task[0], location: task[1], state: task[2])
end

Task.create_indexes
