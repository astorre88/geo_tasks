class User
  include Mongoid::Document

  field :name, type: String
  field :token, type: String
  field :role, type: Integer

  validates_presence_of :name

  has_many :tasks
end
