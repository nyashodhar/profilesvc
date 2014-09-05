#
# Cool hint: How to backup a mongo db
#   http://code.dblock.org/a-rake-task-for-backing-up-a-mongodb-database
#

require 'mongo'

include Mongo
include MongoLoader

the_environment = Rails.env.to_str
load_mongo(the_environment)
