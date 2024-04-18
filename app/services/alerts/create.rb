# frozen_string_literal: true

class Alerts::Create < ApplicationService
  # rubocop:todo Lint/MissingSuper
  def initialize(alert_type:, context:, interaction:, message:, send_notification: false)
    @alert_type = alert_type
    @context = context
    @interaction = interaction
    @message = message
    @send_notification = send_notification
  end
  # rubocop:enable Lint/MissingSuper

  def call
    Alert.create(alert_type: @alert_type, alertable: @interaction, message: @message)

    notify_error if @send_notification
  end

  private

  def notify_error
    Honeybadger.notify(@message, context: error_context)
  end

  def error_context
    @error_context ||= {
      related_to: @context,
      alert_type: @alert_type,
      interaction_type: @interaction.class,
      interaction_id: @interaction.id
    }
  end
end
