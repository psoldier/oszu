# encoding: utf-8

class Payment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination

  # Fields
  field :title,            type: String
  field :salary,           type: Integer
end