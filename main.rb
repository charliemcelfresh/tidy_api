require 'sinatra'
require 'pry'
require 'sequel'
require 'yaml'
require 'logger'
CONFIG = YAML::load_file(File.join(File.dirname(File.expand_path(__FILE__)), 'config.yml'))
# adds methods like constantize and pluralize to String
Sequel.extension :inflector
# lets us use serialized fields in the db -- ie store as json, retrieve as hash, array, etc.
require 'sequel/plugins/serialization'
# serializes any Sequel object as json, using klass_instance.to_json
Sequel::Model.plugin :json_serializer
# add timestamps
Sequel::Model.plugin :timestamps, :update_on_create => true

configure :development do
  DB = Sequel.connect(:adapter=>'postgres',
                      :host=>'localhost',
                      :database=>'tidy_api_development',
                      :user=>'postgres',
                      logger: Logger.new($stdout))
end

configure :test do
  DB = Sequel.connect(:adapter=>'postgres',
                      :host=>'localhost',
                      :database=>'tidy_api_test',
                      :user=>'postgres',
                      logger: Logger.new($stdout))
end
# require all model, lib, etc. ruby files, and all files in their subdirs, if any
# like lib/*.rb and lib/anotherlib/*.rb
["models", "lib", "routes"].each do |dirname|
  Dir.glob(File.join("**", dirname, "**", "*.rb")).each do |file|
    require_relative(file)
  end
end
