class ConvertGrpcError
  require 'google/rpc/code_pb'
  require 'salary_pb'

  class InvalidRequestError < StandardError; end

  GRPC_DETAILS_METADATA_KEY = 'grpc-status-details-bin'
  CUSTOM_ERROR_MESSAGE_CLASSES = [
    SalaryPb::ValidationError
  ]

  class << self
    def convert(error)
      case error
      when ActiveRecord::RecordNotFound
        transform_not_found_error(error)
      when InvalidRequestError
        transform_invalid_request_error(error)
      when ActiveRecord::RecordInvalid
        transform_validation_error(error)
      else
        error
      end
    end

    private

    def unpack_status_details(details)
      details.map do |any|
        unpacked = nil
        CUSTOM_ERROR_MESSAGE_CLASSES.each do |error_message_class|
          unpacked ||= any.unpack(error_message_class)
        end

        unless unpacked
          raise ArgumentError.new("Expected #{CUSTOM_ERROR_MESSAGE_CLASSES.map(&:descriptor).map(&:name).join(', ')}, but got #{any.type_name}")
        end
        unpacked
      end
    end

    # @param record [ApplicationRecord]
    # @params resource_path [Array<String, Array(String, Integer)>]
    # @return [Array<SalaryPb::ValidationError>]
    def build_validation_errors_from_invalid_record(record, resource_path: nil)
      # cf. https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-add
      errors = record.errors
      resource_path ||= [record.class.name.downcase]
      res = []
      errors.details.each do |field, values|
        values.each_with_index do |value, index|
          path_array = field == :base ? resource_path : [*resource_path, field]
          path = build_validation_error_path(path_array)

          type, meta = convert_type_and_meta(value[:error], value.except(:error))
          full_message = errors.full_message(field, errors.messages[field][index])

          res << SalaryPb::ValidationError.new(
            path: path,
            type: type,
            meta: meta.to_json,
            full_message: full_message,
          )
        end
      end
      res
    end

    # @param path_array [Array<String, Array(String, Integer)>]
    # @return [String]
    def build_validation_error_path(path_array)
      path_array.map { |e| e.is_a?(Array) ? "#{e[0]}[#{e[1]}]" : e }.join(".")
    end

    # @param errors [Array<VisitProjectServer::ValidationError>]
    # @return [GRPC::InvalidArgument]
    def wrap_validation_errors_in_grpc_invalid_argument(errors)
      details = errors.map do |error|
        detail = Google::Protobuf::Any.new
        detail.pack(error)
        detail
      end

      GRPC::InvalidArgument.new(
        'validation error',
        {
          ConvertGrpcError::GRPC_DETAILS_METADATA_KEY => Google::Rpc::Status.new(
            code: Google::Rpc::Code::INVALID_ARGUMENT,
            message: 'validation error',
            details: details
          ).to_proto
        }
      )
    end

    # Convert values set by ActiveModel::Validations (e.g. `validates_inclusion_of`, `validates_length_of`) to be more clear.
    def convert_type_and_meta(type, meta)
      if type == :inclusion
        [:unknown_value, meta.except(:value)]
      elsif type == :too_long
        [type, meta.transform_keys { |k| k == :count ? :max_length : k }]
      else
        [type, meta]
      end
    end

    def transform_not_found_error(err)
      GRPC::NotFound.new(
        'resource is not found',
        {
          GRPC_DETAILS_METADATA_KEY => Google::Rpc::Status.new(
            code: Google::Rpc::Code::NOT_FOUND,
            message: 'resource is not found',
            details: []
          ).to_proto
        }
      )
    end

    def transform_invalid_request_error(err)
      # InvalidRequestError message assigns class name by default
      message = err.message == err.class.name ? 'invalid request' : err.message
      GRPC::InvalidArgument.new(
        message,
        {
          GRPC_DETAILS_METADATA_KEY => Google::Rpc::Status.new(
            code: Google::Rpc::Code::INVALID_ARGUMENT,
            message: message,
            details: []
          ).to_proto
        }
      )
    end

    def transform_validation_error(invalid_error)
      errors = build_validation_errors_from_invalid_record(invalid_error.record)
      raise ConvertGrpcError.wrap_validation_errors_in_grpc_invalid_argument(errors)
    end
  end
end
