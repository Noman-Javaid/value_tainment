# frozen_string_literal: true

require_relative 'base'

module DataMigrations
  class CreateAnonymousDefaultUser < Base
    def initialize
      @user = User.where(is_default: true)
                  .or(User.where(email: anon_user_attributes[:email]))
                  .first
      @user ||= User.new(anon_user_full_attributes)

      super(@user.persisted? ? 0 : 1, 'Create Anonymous User')
    end

    private

    def run_migration
      @user.save!
      @user.update!(allow_notifications: false) if @user.allow_notifications?
    end

    def anon_user_attributes
      {
        email: 'anon_user_@minnect.com', first_name: 'Anonymous', last_name: 'User',
        password: '@Anon_u9.', password_confirmation: '@Anon_u9.', role: 'default',
        date_of_birth: '1990-01-01', gender: 'other', phone_number: '13234524426',
        country: 'US', city: 'New York', zip_code: '10018', confirmed_at: Time.current,
        is_default: true
      }
    end

    def anon_user_individual_attributes
      { individual_attributes: { username: '_anon_user_', stripe_customer_id: 'cus_xx' } }
    end

    def anon_user_expert_attributes
      {
        expert_attributes: {
          biography: 'Anonymous User', category_ids: [Category.pick(:id)],
          quick_question_rate: Expert::MINIMUM_QUICK_QUESTION_RATE,
          one_to_one_video_call_rate: Expert::MINIMUM_ONE_TO_ONE_VIDEO_CALL_RATE,
          one_to_five_video_call_rate: Expert::MINIMUM_ONE_TO_FIVE_VIDEO_CALL_RATE,
          extra_user_rate: Expert::MINIMUM_EXTRA_USER_RATE
        }
      }
    end

    def anon_user_full_attributes
      anon_user_attributes.merge(anon_user_individual_attributes)
                          .merge(anon_user_expert_attributes)
    end
  end
end
