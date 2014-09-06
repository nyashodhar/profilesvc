class MongoMigration

  #
  # Example on how to remove the version doc in mongo shell:
  #
  #     use testdb
  #     db.migrations.remove({ _id : 1 })
  #     db.migrations.find()
  #

  def initialize(my_version, target_version)
    @my_version = my_version
    @target_version = target_version
  end

  def migrate

    begin
      current_version = get_current_version()

      if(current_version >= @my_version)
        return "ALREADY APPLIED"
      end

      if(@my_version > @target_version)
        return "SKIPPING"
      end

      # Apply the actual db update
      result = apply_db_update()

      if(result == true)
        store_version()
        return "UPDATE PERFORMED"
      else
        return "UPDATE FAILED"
      end

    rescue => e
      trace = e.backtrace[0,10].join("\n")
      STDOUT.write "=> ERROR when applying update for version #{@my_version} - MESSAGE: #{e.message} - TRACE: #{trace}\n"
    end

  end

  private

  def apply_db_update

  end

  def description
     "<None>"
  end

  #
  # Look in the migrations collection in the
  # database to retrieve the current migration level
  #
  def get_current_version

    version_doc = get_version_doc

    if(version_doc.blank?)
      #STDOUT.write "   get_current_version: No existing version\n"
      return 0
    end

    current_version = version_doc['version'].to_i
    return current_version
  end

  def store_version

    #
    # Example on how to query for profile object based on id:
    #
    #   use developmentdb
    #

    #migration_doc = get_version_doc

    query = Hash.new
    query[:_id] = 1

    version_doc = Hash.new()
    version_doc[:_id] = 1
    version_doc[:version] = @my_version.to_s

    update_params = Hash.new
    update_params[:upsert] = true

    insert_or_update_result = $migrations_coll.update(query, version_doc, update_params)

    number_of_updated_records = insert_or_update_result['nModified'].to_i
    upserted = !insert_or_update_result['upserted'].blank?

    if(number_of_updated_records != 1 && !upserted)
      raise "No upsert happened, and #{number_of_updated_records} records were updated, 1 record should have been updated or inserted"
    end

    #
    # Example result:
    #
    #   insert_or_update_result = {"ok"=>1, "nModified"=>1, "n"=>1}
    #   insert_or_update_result.class = BSON::OrderedHash
    #

  end

  def get_version_doc

    #
    # There should only be a single doc in the migrations collection.
    # It should look something like:
    #
    #      { "version":"201409042100"}
    #

    version_docs = $migrations_coll.find
    version_docs.count

    if(version_docs.count == 0)
      return nil
    end

    if(version_docs.count > 1)
      raise "#{version_docs.count} version docs found. There should be only 1."
    end

    version_doc = version_docs.next

    if(version_doc['version'].blank?)
      raise "The version doc #{version_doc} does not contain a version!"
    end

    return version_doc
  end

end