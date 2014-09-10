require 'mongo'
include Mongo

require "#{Rails.root}/app/helpers/mongo_loader"
require "#{Rails.root}/lib/tasks/util/mongo_migration"
require "#{Rails.root}/lib/tasks/util/mongo_task_initializer"

include MongoTaskInitializer

#
# USAGE:
#   rake db:migrate_mongo[development,201409032100]
#

namespace :db do
  task :migrate_mongo, [:stage, :migration_level] do |t, args|

    the_environment = initialize_mongo(args)
    migration_level = args[:migration_level]

    unless migration_level
      STDOUT.write "ERROR: Must provide a migration level\n"
      exit
    end

    STDOUT.write "=> Running mongodb migration for environment #{the_environment}\n"
    STDOUT.write "=> Migration level: #{migration_level}\n"

    migrations_path = "#{Rails.root}/db/mongo_migration"
    version_to_object = get_migrations(migrations_path, migration_level)

    if(version_to_object.empty?)
      STDOUT.write "=> No migrations found in #{migrations_path}.\n"
      exit
    end

    STDOUT.write "=> Applying migrations:\n"

    version_to_object.keys.each { |version|
      mongo_migration = version_to_object[version]
      migration_result = mongo_migration.migrate()
      STDOUT.write "  #{version}: #{migration_result} (Description: #{mongo_migration.description})\n"
    }

    STDOUT.write "=> Migration complete\n"
  end

  def get_migrations(paths, migration_level)
    paths = Array(paths)
    files = Dir[*paths.map { |p| "#{p}/**/[0-9]*_*.rb" }]

    version_to_object = Hash.new

    files.map do |file|
      version, name = file.scan(/([0-9]+)_([_a-z0-9]*)\.?([_a-z0-9]*)?\.rb\z/).first

      raise "Could not parse migration level from file name #{file}" unless version
      name = name.camelize

      require(File.expand_path(file))

      version = version.to_i
      migration_level = migration_level.to_i

      object = name.constantize.new(version, migration_level)

      version_to_object[version] = object
    end

    version_to_object = Hash[version_to_object.sort]
    return version_to_object
  end

end
