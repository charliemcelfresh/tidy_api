# run like RACK_ENV=test bundle exec rake db:migrate. If you don't specify a RACK_ENV, development
# is used
namespace :db do
  desc "run migrations based on env"
  task :migrate do |t, args|
    ENV['RACK_ENV'] ? db_name = "new_matter_#{ENV['RACK_ENV']}" : db_name = "new_matter_development"
    system "sequel -m db/migrations/ mysql2://root@localhost/#{db_name}"
  end
end

# generate a blank datetime-named migration, like rake generate:migrateion[create_users]
namespace :generate do
  desc 'Generate a timestamped, empty Sequel migration.'
  task :migration, :name do |_, args|
    if args[:name].nil?
      puts 'You must specify a migration name (e.g. rake generate:migration[create_events])!'
      exit false
    end
 
    content = "Sequel.migration do\n  up do\n    \n  end\n\n  down do\n    \n  end\nend\n"
    date_time = DateTime.now
    month = "%02d" % date_time.month
    day = "%02d" % date_time.day
    hour = "%02d" % date_time.hour
    minute = "%02d" % date_time.minute
    
    date_timestamp = "#{date_time.year}#{month}#{day}#{hour}#{minute}"
    
    filename = File.join(File.dirname(__FILE__), 'db', 'migrations', "#{date_timestamp}_#{args[:name]}.rb")
 
    File.open(filename, 'w') do |f|
      f.puts content
    end
 
    puts "Created the migration #{filename}"
  end
end