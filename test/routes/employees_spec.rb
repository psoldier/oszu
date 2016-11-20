# encoding: utf-8
# tests/routes/admin/professions_spec.rb

require File.expand_path '../../../helper.rb', __FILE__

describe "Employee CRUD" do
  before do
    Mongoid.purge!
  end

  let(:valid_attributes) do
    {name: Faker::Name.name, last_name: Faker::Name.last_name, Faker::Internet.email}
  end

  let(:employee) { Employee.spawn }

  it "GET /employees" do
    employee_name = employee.name
    get "/employees"
    assert_equal 200, last_response.status
    last_response.body.must_include employee_name
  end

  it "GET /employees/:id with valid id" do
    get "/employees/#{employee.id}"
    assert_equal 200, last_response.status
    last_response.body.must_include employee.name
  end

  it "GET /employees/:id with invalid id" do
    employee_id_not_exists = 99999
    get "/employees/#{employee_id_not_exists}"
    assert_equal 404, last_response.status
  end

  it "GET /employees/new" do
    get "/employees/new"
    assert_equal 200, last_response.status
    last_response.body.must_include "employee[name]"
  end

  it "POST /employees with valid attributes" do
    post "/employees", {employee: valid_attributes, csrf_token: 'test'}, {"rack.session" => {:csrf_token => 'test'}}
    assert_equal 302, last_response.status
    assert_equal 1, Employee.count
  end

  it "POST /employees without required attributes" do
    post "/employees", {employee: valid_attributes.merge(email: ""), csrf_token: 'test'}, {"rack.session" => {:csrf_token => 'test'}}
    assert_equal 200, last_response.status
    last_response.body.must_include "employee[email]"
    last_response.body.must_include "An error occurred when creating the employee"
  end

  it "POST /employees with undefined attributes" do
    assert_raises(NoMethodError) do
      post "/employees", {employee: valid_attributes.merge(undefined: "undefined"), csrf_token: 'test'}, {"rack.session" => {:csrf_token => 'test'}}
    end
  end

  it "PUT /employees/:id with valid attributes" do
    employee
    put "/employees/#{employee.id}", {employee: { name: "Updated"}, csrf_token: 'test'}, {"rack.session" => {:csrf_token => 'test'}}
    assert_equal 302, last_response.status
    assert_equal "Updated", Employee.first.name
  end

  it "PUT /employees/:id without required attributes" do
    put "/employees/#{employee.id}", {employee: valid_attributes.merge(email: ""), csrf_token: 'test'}, {"rack.session" => {:csrf_token => 'test'}}
    assert_equal 200, last_response.status
    last_response.body.must_include "employee[email]"
    last_response.body.must_include "An error occurred while updating the employee"
  end

  it "PUT /employees/:id with undefined attributes" do
    assert_raises(NoMethodError) do
      put "/employees/#{employee.id}", {employee: valid_attributes.merge(undefined: "undefined"), csrf_token: 'test'}, {"rack.session" => {:csrf_token => 'test'}}
    end
  end

  it "PUT /employees/:id with invalid id" do
    employee_id_not_exists = 99999
    put "/employees/#{employee_id_not_exists}", {csrf_token: 'test'}, {"rack.session" => {:csrf_token => 'test'}}
    assert_equal 404, last_response.status
  end

  it "DELETE /employees/:id with invalid id" do
    employee_id_not_exists = 99999
    delete "/employees/#{employee_id_not_exists}", {csrf_token: 'test'}, {"rack.session" => {:csrf_token => 'test'}}
    assert_equal 404, last_response.status
  end

  it "DELETE /employees/:id with valid id" do
    employee_id = employee.id
    delete "/employees/#{employee_id}", {csrf_token: 'test'}, {"rack.session" => {:csrf_token => 'test'}}
    assert_equal 302, last_response.status
    assert_equal 0, Employee.count
  end

end

describe "Employee Paginate" do
  before do
    Mongoid.purge!
  end

  it "GET /employees with paginate" do
    21.times{ Employee.spawn }
    get "/employees"
    last_response.body.must_include "<a class='page'"
  end

  it "GET /employees without paginate" do
    20.times{ employee.spawn }
    get "/employees"
    last_response.body.wont_include "<a class='page'"
  end

end

describe "Employee Filter" do
  before do
    Mongoid.purge!
  end

  it "GET /employees filters with results" do
    employeeA_name = Employee.spawn.name
    employeeB_name = Employee.spawn.name
    get "/employees", {filter:{name:employeeA_name}}
    last_response.body.must_include employeeA_name
    last_response.body.wont_include employeeB_name
  end

  it "GET /employees filters without results" do
    employee_name = Employee.spawn.name
    get "/employees", {filter:{name:employee_name.reverse}}
    last_response.body.wont_include employee_name
  end

end
