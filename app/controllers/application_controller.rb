class ApplicationController < ActionController::API
  include GrpcControllerConcern

  private

  def pundit_user
    UserContext.new(
      user_id: request.headers['X-Current-User-Id']&.to_i,
      company_id: request.headers['X-Current-Company-Id']&.to_i,
      role: request.headers['X-Current-Role'],
    )
  end
end
