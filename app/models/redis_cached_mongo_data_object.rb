class RedisCachedMongoDataObject

  @@logger = Rails.application.config.logger

  @@ordered_fields = ActiveSupport::OrderedHash.new()
  @@ordered_fields[:id] = {:required => true, :type => Fixnum}

  #
  # Kind of cool hint from here:
  # http://stackoverflow.com/questions/2371044/ruby-methods-and-ordering-of-multiple-default-values
  #

  def initialize(arguments = {}, validate_fields=true)
    build_field_hash_from_args(arguments, validate_fields)
  end

  def serialize
    return @field_hash.to_json
  end

  def store

    if(!@validation_errors.blank?)
      @@logger.error "Object #{serialize} can't be stored due to validation errors #{@validation_errors}"
      return
    end

    store_in_mongo()

    # Mongo storage was successful, store it in redis as well.
    store_in_redis()

  end

  def has_validation_errors
    return !(@validation_errors == nil || @validation_errors.empty?)
  end

  def get_validation_errors
    if(@validation_errors == nil || @validation_errors.empty?)
      return nil
    end
    return @validation_errors.clone
  end

  def set_field(field, value)
    my_ordered_fields = get_ordered_fields
    if(my_ordered_fields[field].blank?)
      raise("Can't set value for field: #{field} is not a valid field. Valid fields are: #{my_ordered_fields.keys}")
    end
    @field_hash[field] = value
  end

  def set_fields(arguments)
    build_field_hash_from_args(arguments, true)
  end

  #
  # This is a factory method that will produce an object
  # instance based on redic cache or mongo.
  #
  # If the object is found in redis, it's returned directly.
  #
  # If the object is not found in redis, but is found in mongo
  # the redis cache is updated before the object is returned
  #
  # It makes no sense to update the redis cache if this method
  # is called as part of an update. In this case, the
  # update_cache parameter should be set to false
  #
  def self.find_by_id(id, update_cache=true)

    object_hash = static_find_in_redis(id)
    cache_hit = false
    if(!object_hash.blank?)
      @@logger.info "Cache hit for #{self.to_s} #{id} in redis"
      cache_hit = true
    else
      object_hash = static_find_in_mongo(id)
      if(object_hash.blank?)
        @@logger.info "#{self.to_s} #{id} not found in redis or mongo"
        return nil
      end
    end

    hash_with_symbol_keys = Hash.new

    # Convert each key into a symbol
    object_hash.keys.each { |arg_key|
      symbol_key = arg_key.to_sym
      hash_with_symbol_keys[symbol_key] = object_hash[arg_key]
    }

    # Filter out the mongo _id field here
    hash_with_symbol_keys.delete(:_id)

    if(!cache_hit && update_cache)
      #
      # It was not a cache hit, so we must have found the object
      # in mongo, add the object to the redis cache.
      #
      static_store_in_redis(hash_with_symbol_keys)
    end

    # Create a new instance - but validation of the field values will be skipped
    data_object = self.new(hash_with_symbol_keys, false)
    return data_object
  end


  private

  def build_field_hash_from_args(arguments, validate_fields)

    my_ordered_fields = get_ordered_fields

    @validation_errors = Array.new

    # Check that all the args given are known fields for this object
    arguments.keys.each { |arg_key|
      if(my_ordered_fields[arg_key] == nil)
        @validation_errors.push(I18n.t("data_object_not_valid_field", :field_name => arg_key))
        #@validation_errors.push("Field #{arg_key} is not a valid field")
        @@logger.error "Field #{arg_key} is not a valid field. Valid fields are: #{my_ordered_fields.keys}"
      end
    }

    #
    # All the fields given are known to be part of this object.
    # If we are invoked as part of a factory method that creates
    # an instance based on existing records, we will skip validation
    # of the values provided for each field here.
    #
    # Validation on the values is only done when an object is being
    # created or updated.
    #

    if(validate_fields == true)
      # Do validation of the values of each field
      my_ordered_fields.keys.each { |field_name|

        arg = arguments[field_name]

        is_required = my_ordered_fields[field_name][:required]
        if(is_required && arg == nil)
          @validation_errors.push(I18n.t("data_object_field_is_required", :field_name => field_name))
          @@logger.error "Field #{field_name} is required and was not specified in the args #{arguments}"
        end

        if(arg != nil)
          expected_type = my_ordered_fields[field_name][:type]
          if(!expected_type.blank? && arg.class != expected_type)
            @validation_errors.push(I18n.t("data_object_field_has_invalid_type", :field_name => field_name))
            @@logger.error "Field #{field_name} is of type #{arg.class} but type #{expected_type} is expected"
          end
          max_length = my_ordered_fields[field_name][:max_length]
          if(!max_length.blank? && arg.to_s.length > max_length)
            @validation_errors.push(I18n.t("data_object_field_has_invalid_length", :field_name => field_name))
            @@logger.error "Field #{field_name} has length #{arg.to_s.length} but max length allowed is #{max_length}"
          end
        end
      }
    end

    #
    # Keep the args in our hash.
    # Note that there could be validation errors.
    # The store operation will not be allowed on this object if there are validation errors
    #

    @field_hash = Hash.new
    arguments.keys.each { |arg_key|
      @field_hash[arg_key] = arguments[arg_key]
    }
  end

  def get_ordered_fields
    return @@ordered_fields
  end

  def get_mongo_collection
    return nil
  end

  def self.static_get_mongo_collection
    return nil
  end

  def self.static_find_in_mongo(id)

    #
    # There should only be a single doc in the collection.
    # with the given id.
    #

    query = Hash.new
    query[:id] = id.to_i

    docs = static_get_mongo_collection.find(query)

    if(docs.count == 0)
      return nil
    end

    if(docs.count > 1)
      raise "#{docs.count} object found matching id #{id}. There should be only 1!"
    end

    doc = docs.next
    return doc
  end

  def self.static_find_in_redis(id)

    redis_key = "#{self.to_s}_#{id}"

    #
    # Error during lookup of cached item in redis should not result in a 500 error
    # Therefore do not allow the error float from there
    #

    redis_key = "#{self.to_s}_#{id}"

    begin
      #field_hash_from_redis = $redis.hgetall redis_key
      json_from_redis = $redis.get(redis_key)
      if(json_from_redis.blank?)
        return nil
      end
      field_hash_from_redis = JSON.parse(json_from_redis)
      return field_hash_from_redis
    rescue => e
      trace = e.backtrace[0,10].join("\n")
      @@logger.error "ERROR when looking up #{self.to_s} #{id} in redis. MESSAGE: #{e.message} - TRACE: #{trace}"
    end

    return nil
  end

  def store_in_mongo

    #
    # EXAMPLES:
    #
    # Insert a new object in mongo
    #
    #   use developmentdb
    #   db.profiles.insert({"_id":7, "id":7, "first_name":"Dude", "last_name":"Fred"})
    #
    # Find an object in mongo:
    #
    #   use developmentdb
    #   db.profiles.find({"id" : 7})
    #
    # Remove an object in mongo:
    #
    #   use developmentdb
    #   db.profiles.remove({"id" : 7})
    #

    query = Hash.new

    # Use the id as the _id as well to make the mongo _id deterministic
    query[:_id] = @field_hash[:id]

    doc = @field_hash.clone
    doc[:_id] = @field_hash[:id]

    # Perform an insert or update
    update_params = Hash.new
    update_params[:upsert] = true

    insert_or_update_result = get_mongo_collection.update(query, doc, update_params)

    number_of_updated_records = insert_or_update_result['nModified'].to_i
    upserted = !insert_or_update_result['upserted'].blank?

    if(number_of_updated_records != 1 && !upserted)
      raise "Could not store #{self.class} doc #{doc} in mongo. No upsert happened, and #{number_of_updated_records} records were updated, 1 record should have been updated or inserted"
    end

    @@logger.info "#{self.class} #{@field_hash[:id]} saved in mongo"

    return true
  end


  def store_in_redis

    #
    # Example:
    #
    #  How to query for a profile in redis
    #
    #  redis-cli
    #  > hgetall Profile_12
    #

    #
    # Failure to store in redis should not be allowed to result 500 error
    # Therefore do not allow the error float from there
    #

    redis_key = "#{self.class}_#{@field_hash[:id]}"

    begin

      #
      # Using redis hash is only option if we want to switch to all strings
      # Redis stores all the items in the cache as strings, so using hash
      # would require to do type conversion if we want to use types in mongo
      #
      # If we don't care about using types in mongo, then we can switch to
      # storing the data in hashes and not just opaque JSON. By storing in
      # opaque JSON we can at least keep string vs number type although
      # all other complex typing is out of the window here....:(
      #
      # This probably needs to be revisited...
      #

      #redis_result = $redis.mapped_hmset(redis_key, @field_hash)
      redis_result = $redis.set(redis_key, @field_hash.to_json)
      # The redis result is a String, expected result is "OK"
      if(!redis_result.eql?("OK"))
        @@logger.error "ERROR when storing #{self.class} #{@field_hash[:id]} in redis, object will not be cached. Result: #{redis_result}"
      else
        @@logger.info "#{self.class} #{@field_hash[:id]} saved in redis using key #{redis_key}"
      end
    rescue => e
      trace = e.backtrace[0,10].join("\n")
      @@logger.error "ERROR when storing #{self.class} #{@field_hash[:id]} in redis, object will not be cached. MESSAGE: #{e.message} - TRACE: #{trace}"
    end
  end


  def self.static_store_in_redis(object_hash)

    redis_key = "#{self.to_s}_#{object_hash[:id]}"

    begin
      #redis_result = $redis.mapped_hmset(redis_key, object_hash)
      redis_result = $redis.set(redis_key, object_hash.to_json)

      # The redis result is a String, expected result is "OK"
      if(!redis_result.eql?("OK"))
        @@logger.error "ERROR - static_store_in_redis() failed when storing #{self.to_s} #{object_hash[:id]} in redis , object will not be cached. Result: #{redis_result}"
      else
        @@logger.info "#{self.to_s} #{object_hash[:id]} saved in redis using key #{redis_key}"
      end
    rescue => e
      trace = e.backtrace[0,10].join("\n")
      @@logger.error "ERROR - static_store_in_redis() failed when storing #{self.to_s} #{object_hash[:id]} in redis, object will not be cached. MESSAGE: #{e.message} - TRACE: #{trace}"
    end
  end

end
