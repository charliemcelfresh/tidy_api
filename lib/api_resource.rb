class ApiResource
  attr_reader :name, :http_verbs
  
  def initialize(name, http_verbs)
    @name, @http_verbs = name, http_verbs
  end

  def model_klass
  	name.to_s.singularize.capitalize.constantize
  end

  def options(http_verb)
    self.class.resources_config[name.to_sym][http_verb]
  end

  def self.resources_config
  	CONFIG[:resources]
  end
  
  def self.run
    permitted_resources.each do |api_resource|
      if api_resource.http_verbs.include?(:collection)
        Sinatra::Application.get "/api/#{api_resource.name.to_s}" do
          api_resource
            .model_klass
            .api_collection # specify includes here
            .to_json(api_resource.options(:collection))
        end
      end

      if api_resource.http_verbs.include?(:get)
        Sinatra::Application.get "/api/#{api_resource.name.to_s}/:id" do
          r = api_resource
            .model_klass
            .where(:id => params[:id]).first || halt(404)
          r.to_json(api_resource.options(:get))
        end
      end

      if api_resource.http_verbs.include?(:post)
        Sinatra::Application.post "/api/#{api_resource.name.to_s}" do
          r = api_resource.model_klass.new(ApiResource.permitted_attributes(params, :post, api_resource))
          halt(500) unless r.save
          status 201
        end
      end
      
      if api_resource.http_verbs.include?(:put)
        Sinatra::Application.put "/api/#{api_resource.name.to_s}/:id" do
          halt(404) unless r = api_resource.model_klass.where(id: params[:id]).first
  				r.set(ApiResource.permitted_attributes(params, :put, api_resource))
          halt(500) unless r.save
          status 200
        end
      end
            
      if api_resource.http_verbs.include?(:delete)
        Sinatra::Application.delete "/api/#{api_resource.name.to_s}/:id" do
          r = api_resource.model_klass.where(id: params[:id]).first || halt(404)
          halt(500) unless r.destroy
        end
      end
    end
  end
  # permitted_attributes put / post for each model class
  def self.permitted_attributes(params, http_verb, api_resource)
  	params.select{|k, v| api_resource.options(http_verb)[:permitted_attributes].include?(k)}
  end
  # A list of all permitted resources, with their permitted http_verbs
  def self.permitted_resources
    CONFIG[:resources].map{|k, v| ApiResource.new(k, v.keys)}
  end
  # convert all strings in the RESOURCES constant to symbols, so we can use them
  # as arguments in the to_json methods in the self.run method
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
