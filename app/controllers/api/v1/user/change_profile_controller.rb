class Api::V1::User::ChangeProfileController < Api::V1::UsersController
  def update
    @user = current_user
    @user.change_current_role!
    render '/api/v1/users/show'
  end
end
