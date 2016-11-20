# encoding: utf-8

class Assignment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination

  # Fields
  field :responsibility,    type: String
  field :duration,          type: Integer

  # Associations
  belongs_to :project, index: true
  belongs_to :employee, index: true

  validates :responsibility, uniqueness: {scope: :employee_id}
end