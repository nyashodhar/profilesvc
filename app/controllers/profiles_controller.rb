class ProfilesController < AuthenticatedController

  ####################################################
  # Look up the profile for the authenticated user
  #
  # GET /profile
  #
  # - 401 if not authenticated
  # - 404 if profile not found (perhaps not yet created)
  # - 200 if request was processed successfully
  #
  # EXAMPLE:
  #
  # curl -v -X GET http://127.0.0.1:3000/profile -H "Accept: application/json" -H "Content-Type: application/json" -H "X-User-Token: kxDZQAp7_Bpink7L3ynE"
  ####################################################
  def get_profile
    profile = Profile.find_by_id(@authenticated_user_id)
    if(profile.blank?)
      logger.info "Could not find profile for user #{@authenticated_user_id}"
      render :status => 404, :json => I18n.t("404response_resource_not_found")
    else
      render :status => 200, :json => profile.serialize()
    end
  end


  ####################################################
  # Create or update profile
  #
  # POST /profile
  #
  # - 401 if not authenticated
  # - 400 if request has a problem
  # - 201 if request was processed successfully
  #
  # EXAMPLE:
  #
  # curl -v -X POST http://127.0.0.1:3000/profile -H "Accept: application/json" -H "Content-Type: application/json" -H "X-User-Token: a6XK1qPfwyNd_HqjsgSS" -d '{"first_name":"Frank", "last_name":"Prank"}'
  ####################################################
  def createOrUpdate

    # TODO: Find a way to propagate error (400 vs 500 etc)

    profile_request_args = request.params[:profile]

    object_update_args = Hash.new
    object_update_args[:id] = @authenticated_user_id

    if(!profile_request_args[:first_name].blank?)
      object_update_args[:first_name] = profile_request_args[:first_name]
    end

    if(!profile_request_args[:last_name].blank?)
      object_update_args[:last_name] = profile_request_args[:last_name]
    end

    profile_to_update = Profile.find_by_id(@authenticated_user_id)
    if(profile_to_update.blank?)
      # We'll be creating a new one..
      profile_to_update = Profile.new(object_update_args)
    else
      # Set our values on the existing one
      profile_to_update.set_fields(object_update_args)
    end

    profile_to_update.store

    the_response = {:status => "updated"}.to_json
    render :status => 201, :json => the_response
  end
end
