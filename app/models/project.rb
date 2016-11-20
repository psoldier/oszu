# encoding: utf-8

class Project
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination

  # Fields
  field :number,           type: Integer
  field :name,             type: String
  field :budget,           type: Integer
  field :location,         type: String

  # Associations
  has_many :assignments

  # Validations
  validates :number, uniqueness: true
end