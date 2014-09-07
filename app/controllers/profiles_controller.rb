class ProfilesController < AuthenticatedController

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
  # curl -v -X POST http://127.0.0.1:3000/profile -H "Accept: application/json" -H "Content-Type: application/json" -H "X-User-Token: a6XK1qPfwyNd_HqjsgSS" -d '{"firstname":"Frank"}'
  ####################################################
  def createOrUpdate

    #logger.info "*** Yay, we're authenticated"
    #logger.info "*** @authenticated_user_id = #{@authenticated_user_id}"

    #profile = Profile.new(:id => 7, :first_name => 'Frank', :last_name => 'Tank')
    #STDOUT.write "*** profile.serialize = #{profile.serialize}\n"
    #profile.store

    #profile = Profile.find_by_id(7)
    #STDOUT.write "*** profile.serialize = #{profile.serialize}\n"
    #STDOUT.write "*** profile.class = #{profile.class}\n"
    #profile.set_field(:first_name, "Hank")
    #profile.store

    the_response = {:status => "updated"}.to_json
    render :status => 201, :json => the_response
  end
end
