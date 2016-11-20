# on app.rb
# require "helpers/errors"
# setup Cuba.plugin Helpers::Errors
module Helpers
  module Errors
    MESSAGES = {
      not_present:          "%{att} is required",
      not_email:            "%{att} is not a valid email address",
      not_url:              "%{att} is not a valid url",
      not_plan_code:        "%{att} is not a valid Plan Code",
      not_unique:           "%{att} has already been taken",
      not_valid:            "%{att} is not valid",
      not_decimal:          "%{att} is not a decimal number",
      not_numeric:          "%{att} is not a number",
      too_low:              "%{att} needs to be higher",
      too_high:             "%{att} needs to be lower",
      not_in_range:         "%{att} is too short",
      too_long:             "%{att} is too long",
      does_not_match:       "%{att} does not match",
      not_equal:            "%{att} does not match",
      zero_or_more:         "%{att} needs to be 0 or higher",
      format_invalid:       "%{att} format is invalid",
      format:               "%{att} format is invalid",
      cell_phone_not_valid: "%{att} cell phone format is invalid"
    }

    def present_errors(hash)
      [].tap do |ret|
        hash.each { |att, errors| ret << full_error_messages(att, errors) }
      end.flatten
    end

    def full_error_messages(att, errors)
      errors.map do |err|
        localize_error(att, err)
      end
    end

    private

    def localize_error(att, err)
      unless MESSAGES.has_key?(err.to_sym)
        raise "You need to define a message in ErrorsHelper::MESSAGES for `#{err}`."
      end

      MESSAGES[err.to_sym] % { att: humanize(att)}
    end

    def humanize(att)
      begin
        humanized = att.join(' and ')
      rescue NoMethodError
        humanized = att.to_s
      end
      humanized.gsub('_', ' ').capitalize
    end
  end
end
