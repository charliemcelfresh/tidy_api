class ApiResource
	attr_reader :name, :model_klass, :name_as_string
  
  def initialize(name)
    @name, @model_klass, @name_as_string = name, name.to_s.singularize.capitalize.constantize, name.to_s
  end
  
	def options(http_verb)
		self.class.resources_config[name][http_verb]
	end

	['collection', 'get', 'post', 'put', 'delete'].each do |http_verb|
		method_name = "#{http_verb}?".to_sym
		define_method(method_name) do
			self.class.resources_config[name] && self.class.resources_config[name][http_verb.to_sym]
		end
	end	
  
  def self.run
    permitted_resources.each do |resource|
			if resource.collection?
	      Sinatra::Application.get "/api/#{resource.name_as_string}" do
	        resource.model_klass.api_collection.to_json(resource.options(:collection))
	      end
			end
			if resource.get?
	      Sinatra::Application.get "/api/#{resource.name_as_string}/:id" do
	        r = resource.model_klass.where(:id => params[:id]).first || halt(404)
	        r.to_json(resource.options(:get))
	      end
			end
			if resource.post?
				Sinatra::Application.post "/api/#{resource.name_as_string}" do
					req = JSON.parse(request.body.read)
					puts req
					# r = resource.model_klass.from_json(req.to_json)
					# r.save
					r = resource.model_klass.create(
						req
					)
					status 201
					r.to_json
				end
			end
			# 
			# put '/api/movies/:id' do
			#   body = JSON.parse request.body.read
			#   movie ||= Movie.get(params[:id]) || halt(404)
			#   halp 500 unless movie.update(
			#     title:    body['title'],
			#     director: body['director'],
			#     synopsis: body['synopsis'],
			#     year:     body['year']
			#   )
			#   format_response(movie, request.accept)
			# end
			# 
			# delete '/api/movies/:id' do
			#   movie ||= Movie.get(params[:id]) || halt(404)
			#   halt 500 unless movie.destroy
			# end
    end
  end

  def self.permitted_resources
    resources_config.keys.map{|r| self.new(r)}
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
