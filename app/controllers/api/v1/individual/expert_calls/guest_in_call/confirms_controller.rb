# frozen_string_literal: true

# Related to APi requests
module Api
  # V1
  module V1
    # related to indivudual's endpoints
    module Individual
      # related to the handle of expert_calls
      module ExpertCalls
        # related to handling guest_in_call instances related to a expert_call
        module GuestInCall
          class ConfirmsController < Api::V1::Individual::ExpertCallsController
            before_action :set_guest_in_call, only: %i[update]

            # PUT /api/v1/individual/expert_calls/:expert_call_id/guest_in_call/confirm
            # chnages the confirmation state of guest_in_call to a expert_call
            def update
              @guest_in_call.update(confirm_params)
              @expert_call = @guest_in_call.expert_call
              render 'api/v1/individual/expert_calls/create'
            end

            private

            def set_guest_in_call
              @guest_in_call = @individual.guest_in_calls.find_by!(
                expert_call_id: params[:expert_call_id]
              )
            end

            def confirm_params
              params.require(:guest_in_call).permit(:confirmed)
            end
          end
        end
      end
    end
  end
end
