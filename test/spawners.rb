require "spawn"
require "faker"

Employee.extend(Spawn).spawner do |employee|
  employee.name       ||= Faker::Name.name
  employee.last_name  ||= Faker::Internet.last_name
  employee.email      ||= Faker::Internet.email
end
