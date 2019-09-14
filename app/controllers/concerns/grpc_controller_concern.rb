module GrpcControllerConcern
  extend ActiveSupport::Concern

  included do
    rescue_from GRPC::NotFound do |e|
      render protobuf: e.to_rpc_status, status: :not_found
    end

    rescue_from GRPC::InvalidArgument do |e|
      render protobuf: e.to_rpc_status, status: :bad_request
    end
  end
end
