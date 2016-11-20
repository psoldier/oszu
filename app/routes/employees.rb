class Employees < Cuba
  define do
    on get, root do
      employees = Employee.paginate(req.params["page"]).asc(:name)
      filter = req.params["filter"]||Hash.new
      employees = employees.in(Hash[filter.map{ |k, v| [k.to_sym, Regexp.new(".*(#{v}).*", Regexp::IGNORECASE)] }]) unless filter.empty?
      render("employees/index", employees: employees, filter: filter, current_section: "employees")
    end

    on "new" do
      employee = Employee.new
      render("employees/new", employee: employee, current_section: "employees")
    end

    on post, root do
      employee_creation = Filters::EmployeeCreation.new(req.params["employee"])
      begin
        if employee_creation.valid? && Employee.create!(employee_creation.attributes)
          session[:notice] = "The Employee was successfully created"
          redirect! "/employees"
        else
          session[:error] = "An error occurred when creating the employee - #{employee_creation.errors} "
          render("employees/new", employee: Employee.new(employee_creation.attributes), current_section: "employees")
        end
      rescue => e
        session[:error] = "Error #{e.message} "
        render("employees/new", employee: Employee.new(), current_section: "employees")
      end
    end

    on ':id' do |id|
      begin
        employee = Employee.find(id)
      rescue Mongoid::Errors::DocumentNotFound
        not_found!
      end

      on get, root do
        render("employees/show", employee: employee, current_section: "employees")
      end

      on "edit" do
        render("employees/edit", employee: employee, current_section: "employees")
      end

      on put do
        on root do
          employee_creation = Filters::EmployeeCreation.new(req.params["employee"])
          begin
            if employee_creation.valid? && employee.update_attributes!(employee_creation.attributes)
              session[:notice] = "Employee updated successfully"
              redirect! "/employees"
            else
              session[:error] = "An error occurred while updating the employee - #{employee_creation.errors}"
              render("employees/edit", employee: employee, current_section: "employees")
            end
          rescue => e
            session[:error] = "Error #{e.message} "
            render("employees/edit", employee: employee, current_section: "employees")
          end
        end
      end

      on delete, root do
        employee.delete
        session[:notice] = "Employee deleted successfully"
        redirect! "/employees"
      end
    end

    not_found!
  end
end