module GrpcControllerConcern
  extend ActiveSupport::Concern

  included do
    rescue_from GRPC::NotFound do |e|
      render protobuf: e.to_rpc_status, status: :not_found
    end

    rescue_from GRPC::InvalidArgument do |e|
      render protobuf: e.to_rpc_status, status: :bad_request
    end

    rescue_from Pundit::NotAuthorizedError do
      status = Google::Rpc::Status.new(
        code: Google::Rpc::Code::PERMISSION_DENIED,
        message: 'Not authorized action',
        details: []
      )
      render protobuf: status, status: :forbidden
    end
  end
end
