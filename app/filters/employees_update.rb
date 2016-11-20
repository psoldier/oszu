# encoding: utf-8

module Filters
  class EmployeeUpdate < ::Scrivener
    # WHITELIST
    attr_accessor :name
    attr_accessor :last_name
    attr_accessor :email
    # WHITELIST END

    # VALIDATIONS
    def validate
      assert_present :email
      assert_email :email
    end
   # VALIDATIONS END

  end
end
