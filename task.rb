class Task
  include Mongoid::Document

  types = ['New', 'Assigned', 'Done']

  field :delivery, type: String
  field :location, type: Array
  field :state, type: Integer, default: 0

  index({location: "2d"})

  validates_presence_of [:delivery, :location]

  belongs_to :user

  def get_state
    types[self.state]
  end
end
