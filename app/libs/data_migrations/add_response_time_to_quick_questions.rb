# frozen_string_literal: true

require_relative 'base'

module DataMigrations
  class AddResponseTimeToQuickQuestions < Base
    def initialize
      @quick_questions = QuickQuestion.where(response_time: nil)

      super(@quick_questions.count, 'Add response time to quick questions')
    end

    private

    def run_migration
      ActiveRecord::Base.transaction do
        @quick_questions.each do |question|
          question.update!(response_time: QuickQuestion::DEFAULT_HOURS_TO_ANSWER)
        end
      end
    end
  end
end
