class Webhooks::Errors::UnhandledEventType < StandardError
  def initialize(event)
    super("Unhandled event type: #{event['type']}")
  end
end
