
include MongoLoader

#
# Initialize mongo - Used in all rake tasks that require
# Mongo initialization
#
module MongoTaskInitializer

  def initialize_mongo(args)
    the_environment = args[:stage]
    unless the_environment
      STDOUT.write "ERROR: Must provide an environment\n"
      exit
    end
    load_mongo(the_environment)
    return the_environment
  end
end