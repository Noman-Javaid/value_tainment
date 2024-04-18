json.extract! expert_call,
              :id,
              :room_id,
              :call_type,
              :title,
              :description,
              :scheduled_call_duration,
              :scheduled_time_start,
              :scheduled_time_end,
              :time_start,
              :time_end,
              :call_status,
              :payment_status,
              :rate,
              :created_at,
              :time_addition_duration_in_seconds,
              :was_helpful,
              :rating,
              :feedback,
              :reviewed_at
json.expert expert_call.expert, partial: 'api/v1/individual/expert_calls/expert', as: :expert
json.individual expert_call.individual, partial: 'api/v1/individual/expert_calls/individual', as: :individual
json.guests expert_call.guest_in_calls, partial: 'api/v1/individual/expert_calls/guest_in_call', as: :guest_in_call
json.category expert_call.category, partial: 'api/v1/individual/expert_calls/category', as: :category
json.time_left_to_accept expert_call.time_left_to_accept
json.time_left_in_start expert_call.time_left_in_start
json.call_status_label expert_call.call_status_label
json.cancellable expert_call.cancellable?(@expert || @individual)
json.refundable_amount expert_call.refundable_amount(@individual)
json.refund_description expert_call.refund_description if @individual.present? && expert_call.pending_for_completion?
json.cancellation_description expert_call.cancellation_description if @individual.present? if @individual.present? && expert_call.pending_for_completion?
json.reschedulable expert_call.reschedulable?
json.time_change_allowed expert_call.time_change_allowed?
json.sub_text expert_call.sub_text
json.cancellation_details expert_call, partial: 'api/v1/individual/expert_calls/cancellation_details', as: :expert_call if expert_call.cancelled?
json.rescheduling_details expert_call.rescheduling_request, partial: 'api/v1/individual/expert_calls/rescheduling_details', as: :expert_call if expert_call.rescheduled? || expert_call.rescheduling_pending?
json.time_change_request_details expert_call.time_change_request, partial: 'api/v1/individual/expert_calls/time_change_request_details', as: :expert_call if expert_call.time_changed? || expert_call.time_change_request_pending?
json.time_left_to_accept_rescheduling_request expert_call.time_left_to_accept_rescheduling_request if expert_call.rescheduling_pending?
json.time_left_to_accept_time_change_request expert_call.time_left_to_accept_time_change_request if expert_call.time_change_request_pending?
json.ask_for_feedback expert_call.ask_for_feedback?