class Product < Sequel::Model

  plugin :serialization, :json, :print_specs
  plugin :serialization, :json, :dimensions
  plugin :serialization, :json, :software_electrical

  serialize_attributes :json, :print_specs
  serialize_attributes :json, :dimensions
  serialize_attributes :json, :software_electrical

end
