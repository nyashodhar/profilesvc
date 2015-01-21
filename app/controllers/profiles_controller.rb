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
    profile = Profile.where(:user_id => @authenticated_user_id).first
    if(profile.blank?)
      logger.info "Could not find profile for user #{@authenticated_user_id}"
      render :status => 404, :json => I18n.t("404response_resource_not_found")
    else
      render :status => 200, :json => profile.to_json
    end
  end


  ####################################################
  # Create or update profile
  #
  # This action supports both POST and PUT. The implementation
  # is identical since the underlying implementation is using
  # and 'upsert' operation that can handle both initial creation
  # update to existing record.
  #
  # POST /profile OR PUT /profile
  #
  # - 401 if not authenticated
  # - 422 if the request has a problem
  # - 201 if request was processed successfully
  #
  # EXAMPLE:
  #
  # curl -v -X POST http://127.0.0.1:3000/profile -H "Accept: application/json" -H "Content-Type: application/json" -H "X-User-Token: a6XK1qPfwyNd_HqjsgSS" -d '{"first_name":"Frank", "last_name":"Prank"}'
  ####################################################
  def create_or_update
    object_update_args = prepare_profile_update_args

    profile_to_update = Profile.where(:user_id => @authenticated_user_id).first

    is_saved = if profile_to_update
      profile_to_update.update_attributes(object_update_args)
    else
      # We'll be creating a new one..
      profile_to_update = Profile.new(object_update_args)
      profile_to_update.save
    end

    unless is_saved
      # Note: The validation errors from the data object are already localized
      render :status => 422, :json => { :error => profile_to_update.errors }
      return
    end

    render :status => 201, :json => profile_to_update.to_json
  end

  private

  def prepare_profile_update_args
    profile_request_args = request.params[:profile]

    object_update_args = Hash.new
    object_update_args[:user_id] = @authenticated_user_id

    if(!profile_request_args[:first_name].blank?)
      object_update_args[:first_name] = profile_request_args[:first_name]
    end

    if(!profile_request_args[:last_name].blank?)
      object_update_args[:last_name] = profile_request_args[:last_name]
    end

    return object_update_args
  end

end
