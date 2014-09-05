class Profile < RedisCachedMongoDataObject

  @@subthing_ordered_fields = @@thing_ordered_fields.clone
  @@subthing_ordered_fields[:first_name] = true
  @@subthing_ordered_fields[:last_name] = true

  def get_ordered_fields
    @@subthing_ordered_fields
  end
end

