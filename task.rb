class Task
  include Mongoid::Document
  include Mongoid::Geospatial

  field :delivery, type: String
  field :location, type: Point
  field :state, type: Integer, default: 0

  spatial_index :location

  validates_presence_of [:delivery, :location]

  belongs_to :user
end
