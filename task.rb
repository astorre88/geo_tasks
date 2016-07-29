class Task
  include Mongoid::Document

  field :delivery, type: String
  field :location, type: Array
  field :state, type: Integer

  index({location: "2d"})

  validates_presence_of [:delivery, :location]
end
