class SalaryServer < Salary::SalaryService::Service
  # @param request [SalaryPb::GetSalaryRequest]
  # @return [SalaryPb::GetSalaryResponse]
  def get_salary(request, _call)
    raise GRPC::InvalidArgument unless request.user_id > 0

    user = User.find(request.user_id)

    SalaryPb::GetSalaryResponse.new(
      salary: user.to_pb_salary_message
    )
  end

  # @param request [SalaryPb::ListSalariesRequest]
  # @return [SalaryPb::ListSalariesResponse]
  def list_salary(request, _call)
    raise GRPC::InvalidArgument unless request.company_id > 0

    company = Company.find(request.company_id)

    SalaryPb::ListSalariesResponse.new(
      salaries: company.employees.map(&:to_pb_salary_message)
    )
  end

  # @param request [SalaryPb::DoubleBonusRequest]
  # @return [Google::Protobuf::Empty]
  def double_bonus(request, _call)
    raise GRPC::InvalidArgument unless request.user_id > 0

    user = User.find(request.user_id)
    user.double_bonus!

    Google::Protobuf::Empty.new
  end

  # @param request [SalaryPb::UpdateMonthlySalaryRequest]
  # @return [Google::Protobuf::Empty]
  def update_monthly_salary(request, _call)
    raise GRPC::InvalidArgument unless request.user_id > 0
    raise GRPC::InvalidArgument unless request.monthly > 0

    user = User.find(request.user_id)
    user.update!(monthly: request.monthly)

    Google::Protobuf::Empty.new
  end
end
