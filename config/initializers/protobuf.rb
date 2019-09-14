Mime::Type.register "application/protobuf", :protobuf, %w[application/x-protobuf application/vnd.google.protobuf]
ActionController::Renderers.add :protobuf do |obj, _options|
  send_data obj.to_proto, type: Mime[:protobuf]
end
