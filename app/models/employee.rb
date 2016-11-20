# encoding: utf-8

class Employee
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination

  # Fields
  field :number,           type: Integer
  field :name,             type: String
  field :last_name,        type: String
  field :email,            type: String
  field :title,            type: String

  # Associations
  has_many :assignments

  index({ email: 1 }, { unique: true })

  # Validations
  validates :email, :number, uniqueness: true

  def self.[](id)
    self.find(id)
  end

  def self.fetch(email)
    where(email: email).first
  end

end