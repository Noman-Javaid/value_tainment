class ExpertCalls::CapturePaymentWorker
  include Sidekiq::Worker
  def perform
    scheduled_calls = ExpertCall.coming_events.where(call_status: 'scheduled', payment_status: 'requires_capture')
    scheduled_calls.each do |expert_call|
      Stripes::Payments::CapturePaymentHandler.call(expert_call)
    end
  end
end
