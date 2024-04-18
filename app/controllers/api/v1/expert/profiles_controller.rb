class Api::V1::Expert::ProfilesController < Api::V1::Expert::ExpertsController
  def create
    @user = @expert.user
    @user.start_setting_profile
    @user.create_individual!(profile_params)
    @user.mark_as_profile_set
    @user.change_current_role!
    @profile = true
    render '/api/v1/users/show'
  end

  private

  def profile_params
    params.require(:profile).permit(:username)
  end
end
