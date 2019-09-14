class ApplicationPolicy
  attr_reader :context, :request

  def initialize(context, request)
    @context = context
    @request = request.is_a?(Array) ? request.last : request
  end

  private

  def shacho?
    role == "shacho"
  end

  def bucho_or_more?
    role.in?("shacho", "bucho")
  end
end

class UserContext
  attr_reader :user_id, :company_id, :role

  def initialize(user_id:, company_id:, role:)
    @user_id = user_id
    @company_id = company_id
    @role = role
  end
end
