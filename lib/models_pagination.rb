module Mongoid
  module Pagination
    PER_PAGE = 20
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        scope :paginate, -> (page) { limit(PER_PAGE).skip((page.nil? ? 0 : (( page.to_i < 1 ? 1 : page.to_i) - 1)) * PER_PAGE) }
      end
    end

    module ClassMethods
      def pages
        (self.count / PER_PAGE.to_f).ceil
      end
    end

  end
end