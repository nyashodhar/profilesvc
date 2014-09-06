class RedisCachedMongoDataObject

  # Special arg, used to initialize from JSON
  JSON_DOC_ARG = :json_doc;

  @@thing_ordered_fields = ActiveSupport::OrderedHash.new()
  @@thing_ordered_fields[:id] = true

  #
  # Kind of cool hint from here:
  # http://stackoverflow.com/questions/2371044/ruby-methods-and-ordering-of-multiple-default-values
  #

  def initialize(arguments = {})

    @field_hash = Hash.new

    build_field_hash_from_args(arguments)

    #if(arguments[JSON_DOC_ARG].blank?)
    #  # Initialize from JSON (probably pulled from db)
    #  build_field_hash_from_args(arguments)
    #else
    #  # Initialize from itemized hash (typically when used first time)
    #  build_field_hash_from_json(arguments[JSON_DOC_ARG])
    #end
  end

  def serialize
    return @field_hash.to_json
  end

  def store
    ### TODO: Implement hybrid mongo/redis operation
    store_in_mongo()
  end

  private

  def build_field_hash_from_args(arguments)

    my_ordered_fields = get_ordered_fields

    # Check that all required fields are present?
    my_ordered_fields.keys.each { |field_name|
      is_required = my_ordered_fields[field_name]
      if(is_required && arguments[field_name].blank?)
        raise("Field #{field_name} is required and was not specified in the args (#{arguments}")
      end
    }

    # Check that all the args given are valid for the object
    arguments.keys.each { |arg_key|
      if(my_ordered_fields[arg_key].blank?)
        raise("Field #{arg_key} is not a valid field. Valid fields are: #{my_ordered_fields.keys}")
      end
    }

    # Everything is cool, accept the args
    arguments.keys.each { |arg_key|
      @field_hash[arg_key] = arguments[arg_key]
    }
  end

  def build_field_hash_from_json(json_doc)

    hash_from_json = JSON.parse(json_doc)
    hash_with_symbol_keys = Hash.new

    # Convert each key into a symbol
    hash_from_json.keys.each { |arg_key|
      symbol_key = arg_key.to_sym
      hash_with_symbol_keys[symbol_key] = hash_from_json[arg_key]
    }

    # Then build the object normally..
    build_field_hash_from_args(hash_with_symbol_keys)
  end

  def get_ordered_fields
    return @@thing_ordered_fields
  end

  def store_in_mongo

    #
    # EXAMPLES:
    #
    # Insert a new profile in mongo
    #
    #   use developmentdb
    #   db.profiles.insert({"_id":7, "id":7, "first_name":"Dude", "last_name":"Fred"})
    #
    # Find a profile in mongo:
    #
    #   use developmentdb
    #   db.profiles.find({"id" : 7})
    #
    # Remove a profile in mongo:
    #
    #   use developmentdb
    #   db.profiles.remove({"id" : 7})
    #

    query = Hash.new

    # Use the id as the _id as well to make the mongo id deterministic
    query[:_id] = @field_hash[:id]

    doc = @field_hash.clone
    doc[:_id] = @field_hash[:id]

    # Perform an insert or update
    update_params = Hash.new
    update_params[:upsert] = true

    insert_or_update_result = $profiles_coll.update(query, doc, update_params)

    number_of_updated_records = insert_or_update_result['nModified'].to_i
    upserted = !insert_or_update_result['upserted'].blank?

    if(number_of_updated_records != 1 && !upserted)
      raise "Could not store store profile doc #{doc}. No upsert happened, and #{number_of_updated_records} records were updated, 1 record should have been updated or inserted"
    end

    return true
  end

end
