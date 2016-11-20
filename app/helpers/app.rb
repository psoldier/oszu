require 'logger'
require 'rack/file'

module Helpers
  module App

    def day_of_week(day)
      days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']
      days[day]
    end

    def months_of_year(month)
      months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
      months[month-1]
    end

    def hours_format(hour)
      Time.parse("#{hour}:00").strftime("%l:00 %P")
    end

    def date_time_format(date_time, with_time=false)
      format = "%m/%d/%y#{" %I:%M %p" if with_time}"
      date_time.strftime(format)
    end

    def from_session_or_params(key)
     session[key.to_s] || req.params[key.to_s]
    end

    def titleize(str)
      str.downcase.split(/ |\_/).map(&:capitalize).join(" ")
    end

    def current_section; @current_section.to_s;end

    def truncate_string(lengthy,text)
      ((text.length>lengthy) ? "#{text[0..lengthy]}..." : text) unless text.to_s.empty?
    end

    def display_paginate opts={}
      opts[:page] = opts[:page] ? opts[:page].to_i : 1
      opts[:optional] = opts[:filter] ? Rack::Utils.build_nested_query({filter:opts[:filter]}) : ""
      opts[:optional] += opts[:order] ? "&order=#{opts[:order]}" : ""
      if opts[:pages] > 1
        html = "<li class='previous #{ 'disabled' if opts[:page] == 1 }'>"
        if opts[:page] == 1
          html += "<a> &larr; Previous</a></li>"
        else
          html += "<a class='page' href='#{opts[:url_index]}?page=#{(opts[:page] -1)}#{"&" + opts[:optional] unless opts[:optional].blank?}'>&larr; Previous</a></li>"
        end
        html +="<li class='next #{'disabled' if opts[:page] == opts[:pages] }'>"
        if opts[:page] == opts[:pages]
          html += "<a>Next &rarr;</a></li>"
        else
          html += "<a class='page' href='#{opts[:url_index]}?page=#{(opts[:page] +1)}#{"&" + opts[:optional] unless opts[:optional].blank?}'>Next &rarr;</a></li>"
        end
      end
      html||''
    end

    def paginate_count(total, per_page)
      count = total / per_page
      (total % per_page) == 0 ? count : count + 1
    end

    def inputs_class(value)
      value.blank? ? 'edit-empty' : 'edit-complete'
    end

    def log
      @log ||= begin
        logger = Logger.new("log/error.log", 10, 1024000)
        logger.level = Logger.const_get((ENV['LOGLEVEL'] || 'info').upcase)
        logger
      end
    end

    def check_grid(data)
      if data
        "<i class='glyphicon glyphicon-ok text-success'></i>"
      else
        "<i class='glyphicon glyphicon-remove text-danger'></i>"
      end
    end

    # Render no content and halt.
    def no_content!
      res.headers.delete("Content-Type")
      res.status = 204
      halt(res.finish)
    end

    # Render a 404 page into the response and halt.
    def not_found!
      res.status = 404
      render "public/shared/404"
      halt res.finish
    end

    # Render a 500 page into the response and halt.
    def application_error!
      res.status = 500
      render "public/shared/500"
      halt res.finish
    end

    # Halt the execution of a route handler and redirect.
    #
    # @param path [String]
    def redirect!(path)
      res.redirect path
      halt res.finish
    end

    # Determine if the request includes the Mime-Type on the Accepts header.
    #
    # @param mimetype [String]
    #
    # @return [Boolean]
    def accept?(mimetype)
      String(env["HTTP_ACCEPT"]).split(",").any? { |s| s.strip == mimetype }
    end

    # Render a file to the response.
    #
    # @param path [String]
    #   The relative file path.
    # @param status_code [Fixnum]
    # @param cached [Boolean] (false)
    #   If true, the response might return a 304.
    def render_file(path, status_code = 200, cached = false)
      file = Rack::File.new(nil)
      file.path = path
      status, headers, body = file.serving(env)
      unless cached
        headers.delete("Last-Modified")
      end
      halt [status, headers, body]
    end
  end
end
