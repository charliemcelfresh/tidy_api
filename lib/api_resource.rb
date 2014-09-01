class ApiResource
	
	attr_reader :name, :model_klass, :name_as_string
  
  def initialize(name)
    @name, @model_klass, @name_as_string = name, name.to_s.singularize.capitalize.constantize, name.to_s
  end
  
	def collection_options(http_method)
		self.class.resources_config[name][:collection][http_method]
	end
	
	def options(http_method)
		self.class.resources_config[name][http_method]
	end
  
  def self.run
    permitted_resources.each do |resource|      
      Sinatra::Application.get "/api/#{resource.name_as_string}" do
        resource.model_klass.to_json(resource.collection_options(:get))
      end
      Sinatra::Application.get "/api/#{resource.name_as_string}/:id" do
        r = resource.model_klass.where(:id => params[:id]).first || halt(404)
        r.to_json(resource.options(:get))
      end
    end
  end

  def self.permitted_resources
    CONFIG[:permitted_resources].map{|r| self.new(r.to_sym)}
  end
  
	def self.resources_config
		ApiResource.symbolize_every_string(CONFIG[:resources])
	end
  
	# convert all strings in the RESOURCES constant to symbols, so we can use them
	# as arguments in the to_json methods in the self.run method
	def self.symbolize_every_string(resources)
		h = {}
		resources.each do |k, v|
			if v.kind_of?(Hash)
				h[k] = symbolize_every_string(v)
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
