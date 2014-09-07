class Profile < RedisCachedMongoDataObject

  @@profile_ordered_fields = @@ordered_fields.clone
  @@profile_ordered_fields[:first_name] = false
  @@profile_ordered_fields[:last_name] = false

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

