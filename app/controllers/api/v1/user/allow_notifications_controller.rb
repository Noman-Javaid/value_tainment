class Api::V1::User::AllowNotificationsController < Api::V1::UsersController
  def update
    @user = current_user
    @user.update!(user_params)
    render '/api/v1/users/show'
  end

  private

  def user_params
    params.require(:user).permit(:allow_notifications)
  end
end
