class Api::V1::User::ProfilePictureController < Api::V1::UsersController
  def update
    @user = current_user
    @user.picture.attach(user_params[:picture])
    @user.save! unless @user.valid?
    render '/api/v1/users/show'
  end

  private

  def user_params
    params.require(:user).require(:picture)
    params.require(:user).permit(:picture)
  end
end
