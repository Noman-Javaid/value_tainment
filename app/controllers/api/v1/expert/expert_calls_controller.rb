class Api::V1::Expert::ExpertCallsController < Api::V1::Expert::ExpertsController
  skip_before_action :app_version_supported?

  def index
    @expert_calls = @expert.expert_calls.scheduled.coming_events
                           .or(@expert.expert_calls.requires_confirmation.coming_events)
                           .or(@expert.expert_calls.requires_time_change_confirmation.coming_events)
                           .or(@expert.expert_calls.declined.coming_events)
                           .or(@expert.expert_calls.requires_reschedule_confirmation
                                      .coming_events)
                           .or(@expert.expert_calls.ongoing)
                           .most_recent
                           .page(params[:page])
                           .per(params[:per_page])
  end

  def show
    @expert_call = @expert.expert_calls.find(params[:expert_call_id])
    render '/api/v1/individual/expert_calls/show'
  end

  def new_chat_room
    @expert_call = @expert.expert_calls.find(params[:expert_call_id])
    if @expert_call.chat_room.present?
      render json: @expert_call.chat_room
    else
      chat_room = TwilioServices::CreateConversation.call(@expert_call.id)
      if chat_room[:error].present?
        json_error_response(chat_room[:error], :bad_request)
      else
        render json: chat_room
      end
    end
  end

  def chat_room
    @expert_call = @expert.expert_calls.find(params[:expert_call_id])
    render json: {chat_room: @expert_call.chat_room}
  end

  private

  def set_expert_call
    @expert_call = @expert.expert_calls.find(params[:id])
  end

end
