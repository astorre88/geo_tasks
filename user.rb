class User
  include Mongoid::Document

  roles = ['Manager', 'Driver']

  field :name, type: String
  field :token, type: String
  field :role, type: Integer

  validates_presence_of :name

  has_many :tasks

  def get_role
    roles[self.role]
  end
end
