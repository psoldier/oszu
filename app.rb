require 'cuba'
require 'cuba/safe'
require 'cuba/render'
require 'tilt/erb'
require 'rack'
require 'rack/deflater'
require 'rack/content_type'
require 'rack/showexceptions'
require 'mongoid'
require 'scrivener'
require 'rack/parser'

# set default environment
ENV["RACK_ENV"] ||= 'development'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# database
Mongoid.load!("./config/mongoid.yml")

# Require all application files
Dir["./lib/**/*.rb"].sort.each            { |rb| require rb }
Dir["./app/models/**/*.rb"].sort.each     { |rb| require rb }
Dir["./app/helpers/**/*.rb"].sort.each    { |rb| require rb }
Dir["./app/filters/**/*.rb"].sort.each    { |rb| require rb }

# Load rack middlewares
Cuba.use Rack::Deflater
Cuba.use Rack::ContentType, 'text/html; charset=utf-8'
Cuba.use Rack::MethodOverride
Cuba.use Rack::Head
Cuba.use Rack::Session::Cookie, key: '__oszu__', secret: Cuba.settings["SESSION_SECRET"]
Cuba.use Rack::Static, root: 'public', urls: %w(/css /fonts /js /robots.txt)
Cuba.use Rack::ShowExceptions if ENV["RACK_ENV"] == "development"
Cuba.use Rack::Parser,
  parsers:  { "application/json" => proc { |data| JSON.parse(data) } },
  handlers: { %r(json) => proc { |err, type| [400, {}, ["Bad Request: #{err.to_s}"]] } }

# Cuba Helpers
Cuba.plugin Cuba::Safe
Cuba.plugin Cuba::Render
Cuba.plugin Cuba::ContentFor
Cuba.plugin Cuba::With
Cuba.plugin Helpers::App
Cuba.plugin Helpers::Errors
Cuba.plugin Helpers::Queries

Cuba.settings[:render][:views] = './app/views/'
#Cuba.settings[:render][:layout] = 'public/layout'

Dir["./app/routes/**/*.rb"].sort.each     { |rb| require rb }

# Finally, define the application routes.
Cuba.define do
  begin

    on csrf.unsafe? do
      csrf.reset!

      res.status = 403
      res.write("Not authorized")

      halt(res.finish)
    end

    on "employees" do
      run Employees
    end

    on root do
      render "index"
    end

    on default do
      res.redirect "/", 302
    end

  rescue Exception => e
    if ENV["RACK_ENV"] == "production"
      log.error([e.message, e.backtrace].join("\n"))
      application_error!
    else
      raise e
    end
  end
end
