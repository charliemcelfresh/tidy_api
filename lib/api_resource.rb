class ApiResource
	
	attr_reader :name, :model_klass, :name_as_string
  
  def initialize(name)
    @name, @model_klass, @name_as_string = name, name.to_s.singularize.capitalize.constantize, name.to_s
  end
  
	def options(http_verb)
		self.class.resources_config[name][http_verb]
	end
	
	def collection?
		return true if self.class.resources_config[name][:collection]
		false
	end
	
	def get?
		return true if self.class.resources_config[name][:get]
		false
	end
	
	def post?
		return true if self.class.resources_config[name][:post]
		false
	end
	
	def put?
		return true if self.class.resources_config[name][:put]
		false
	end
	
	def delete?
		self.class.resources_config[name][:delete]
	end
  
  def self.run
    permitted_resources.each do |resource|
			if resource.collection?
	      Sinatra::Application.get "/api/#{resource.name_as_string}" do
	        resource.model_klass.to_json(resource.options(:get))
	      end
			end
			if resource.get?
	      Sinatra::Application.get "/api/#{resource.name_as_string}/:id" do
	        r = resource.model_klass.where(:id => params[:id]).first || halt(404)
	        r.to_json(resource.options(:get))
	      end
			end
    end
  end

  def self.permitted_resources
    CONFIG[:permitted_resources].map{|r| self.new(r.to_sym)}
  end
  
	def self.resources_config
		ApiResource.symbolize_strings(CONFIG[:resources])
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
