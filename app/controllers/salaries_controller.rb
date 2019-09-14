class SalariesController < ApplicationController
  def get_salary
    req = SalaryPb::GetSalaryRequest.decode(request.body.read)
    res = SalaryServer.new.get_salary(req, nil)

    render protobuf: res
  end

  def list_salary
    req = SalaryPb::ListSalariesRequest.decode(request.body.read)
    res = SalaryServer.new.list_salary(req, nil)

    render protobuf: res
  end

  def double_bonus
    req = SalaryPb::DoubleBonusRequest.decode(request.body.read)
    req = SalaryServer.new.double_bonus(req, nil)

    render protobuf: res
  end

  def update_monthly_salary
    req = SalaryPb::UpdateMonthlySalaryRequest.decode(request.body.read)
    req = SalaryServer.new.update_monthly_salary(req, nil)

    render protobuf: res
  end
end
