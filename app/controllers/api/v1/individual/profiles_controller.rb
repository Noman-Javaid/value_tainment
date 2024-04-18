class Api::V1::Individual::ProfilesController < Api::V1::Individual::IndividualsController
  def create
    @user = @individual.user
    @user.start_setting_profile
    category_ids = params[:profile][:category_ids]
    expert = @user.build_expert(profile_params)
    if expert.save
      expert.category_ids = category_ids
      expert.save!
    end

    @user.mark_as_profile_set
    @user.change_current_role!
    @profile = true
    render '/api/v1/users/show'
  end

  private

  def profile_params
    params.require(:profile).permit(
      :biography, :website_url, :linkedin_url, :quick_question_rate,
      :quick_question_video_rate, :video_call_rate, :quick_question_text_rate,
      :one_to_one_video_call_rate, :one_to_five_video_call_rate,
      :extra_user_rate, :twitter_url, :instagram_url
    )
  end
end
