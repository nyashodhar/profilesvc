class ProfilesIdIndex < MongoMigration

  #
  # How to drop this index again in mongo shell:
  #
  #  use developmentdb
  #  db.profiles.dropIndex({"id":1})
  #
  # How to show the current indexes on the profiles collection:
  #
  #  db.profiles.getIndexes()
  #

  #
  # How to run migrate command to ensure that this update is applied:
  #
  #   rake db:migrate_mongo[development,201409032100]
  #

  #
  # This update ensure that there is a unique index on the
  # id field in the profiles collection
  #
  def apply_db_update

    begin

      id_field_unique_index_spec = Hash.new
      id_field_unique_index_spec["id"] = 1

      result = $profiles_coll.ensure_index(id_field_unique_index_spec)

      # Note: In case of success, result is a string with value 'id_1'

      if(result.eql?("id_1"))
        return true
      end

      STDOUT.write "=> ERROR when adding unique index for id field in profiles : #{result.inspect}\n"
      return false

    rescue => e
      trace = e.backtrace[0,10].join("\n")
      STDOUT.write "=> ERROR when adding unique index for id field in profiles! - MESSAGE: #{e.message} - TRACE: #{trace}\n"
      return false
    end

  end

  def description
    return "Unique index id field in profiles"
  end

end