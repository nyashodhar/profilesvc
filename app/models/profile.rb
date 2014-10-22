class Profile < RedisCachedMongoDataObject
  
  
  @@profile_ordered_fields = @@ordered_fields.clone
  @@profile_ordered_fields[:first_name] = {:required => false, :max_length => 256, :type => String}
  @@profile_ordered_fields[:last_name] = {:required => false, :max_length => 256, :type => String}
  @@profile_ordered_fields[:image_id] = {:required => false, :max_length => 256, :type => String}

  private

  def self.static_get_mongo_collection
    return $profiles_coll
  end

  def get_mongo_collection
    return $profiles_coll
  end

  def get_ordered_fields
    @@profile_ordered_fields
  end
end

