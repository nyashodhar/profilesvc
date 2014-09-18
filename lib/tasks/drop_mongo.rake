require 'mongo'
include Mongo

require "#{Rails.root}/app/helpers/mongo_loader"
require "#{Rails.root}/lib/tasks/util/mongo_task_initializer"

include MongoTaskInitializer

#
# This task drops the entire mongo db of the profile service.
#
# USAGE:
#   rake db:drop_mongo[development]
#

namespace :db do
  task :drop_mongo, [:stage] do |t, args|

    ####################################
    # MAKE SURE ENV IS NOT PRODUCTION
    ####################################

    if(args[:stage].downcase.eql?("production"))
      STDOUT.write "ERROR: Invalid value for environment: #{args[:stage]}\n"
      STDOUT.write "ERROR: DROP OF MONGO ON PRODUCTION NOT ALLOWED\n"
      exit
    end

    the_environment = initialize_mongo(args)
    the_db_name = $mongo_config['dbname']

    begin

      drop_result = $mongo_client.drop_database(the_db_name)

      # Example expected result:  {"dropped"=>"developmentdb", "ok"=>1.0}
      if(drop_result['dropped'].eql?(the_db_name) && drop_result['ok'].to_i.eql?(1))
        STDOUT.write "The db #{the_db_name} was dropped!\n"
      else
        STDOUT.write "ERROR: The db #{the_db_name} could not be dropped. Result: #{drop_result}\n"
      end

    rescue => e
      trace = e.backtrace[0,10].join("\n")
      STDOUT.write "=> ERROR when dropping the db #{the_db_name} for environment #{the_environment} - MESSAGE: #{e.message} - TRACE: #{trace}\n"
    end
  end
end