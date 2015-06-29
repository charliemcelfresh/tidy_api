class HttpEndpoint
  attr_reader :api_resource
  BASE_PATH = '/api/v1/'

  def initialize(api_resource)
    @api_resource = api_resource
  end

  def name
    api_resource.name.to_s
  end

  def json_options
    (endpoint && endpoint[:json_options]) || nil
  end

  def permitted_attributes(params)
    p = endpoint[:permitted_attributes]
    params.select{|k, v| p.include?(k)}
  end

  def path
    BASE_PATH + name
  end

  def eager
    (endpoint && endpoint[:eager] && endpoint[:eager].to_sym) || {}
  end

  def endpoint
    CONFIG[:resources][api_resource.name][self.class.to_s.demodulize.underscore.to_sym]
  end
end

class HttpEndpoint::GetCollection < HttpEndpoint; end

class HttpEndpoint::Get < HttpEndpoint
  def path
    BASE_PATH + name + '/:id'
  end
end

class HttpEndpoint::Post < HttpEndpoint; end

class HttpEndpoint::Put < HttpEndpoint
  def path
    BASE_PATH + name + '/:id'
  end
end

class HttpEndpoint::Delete < HttpEndpoint
  def path
    BASE_PATH + name + '/:id'
  end
end
