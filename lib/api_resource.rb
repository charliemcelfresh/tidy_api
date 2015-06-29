class ApiResource
  attr_reader :name, :permitted_endpoints, :get, :get_collection, :post, :put, :delete
  
  def initialize(name, permitted_endpoints)
    @name, @permitted_endpoints = name, permitted_endpoints
    set_permitted_endpoints
  end

  def model_klass # like Comment, or User
  	name.to_s.singularize.camelize.constantize
  end
  # sets instance variables like @get = HttpEndpoint::Get.new(self), for each
  # permitted_endpoint for a given api_resource
  def set_permitted_endpoints
  	permitted_endpoints.each do |p|
  		k = p.to_s.camelize
  		instance_variable_set("@#{p.to_s}", "HttpEndpoint::#{k}".constantize.new(self))
  	end
  end

  def self.run
    permitted_api_resources.each do |api_resource|
      if api_resource.get_collection
        Sinatra::Application.get api_resource.get_collection.path do
          api_resource
            .model_klass
            .eager(api_resource.get_collection.eager)
            .to_json(api_resource.get_collection.json_options)
        end
      end

      if api_resource.get
        Sinatra::Application.get api_resource.get.path do
          r = api_resource
            .model_klass
            .eager(api_resource.get.eager)
            .where(:id => params[:id]).first || halt(404)
          r.to_json(api_resource.get.json_options)
        end
      end

      if api_resource.post
       Sinatra::Application.post api_resource.post.path do
          r = api_resource.model_klass.new(api_resource.post.permitted_attributes(params))
          halt(500) unless r.save
          status 201
        end
      end
      
      if api_resource.put
        Sinatra::Application.put api_resource.put.path do
          halt(404) unless r = api_resource.model_klass.where(id: params[:id]).first
  				r.set(api_resource.put.permitted_attributes(params))
          halt(500) unless r.save
          status 200
        end
      end
            
      if api_resource.delete
        Sinatra::Application.delete api_resource.delete.path do
          r = api_resource.model_klass.where(id: params[:id]).first || halt(404)
          halt(500) unless r.destroy
          status 204
        end
      end
    end
  end

  def self.permitted_api_resources
    CONFIG[:resources].map{|k, v| ApiResource.new(k, v.keys)}
  end
  # utility method that converts all strings in the RESOURCES constant to symbols
  # so we can use them as arguments in the to_json methods in the self.run method
  def self.symbolize_strings(resources)
    h = {}
    resources.each do |k, v|
      if v.kind_of?(Hash)
        h[k] = symbolize_strings(v)
      elsif v.kind_of?(Array)
        h[k] = v.map{|e| e.kind_of?(String) ? e.to_sym : e}
      elsif v.kind_of?(String)
        h[k] = v.to_sym
      else
        h[k] = v
      end
    end
    h
  end
end
