# frozen_string_literal: true

require_relative 'base'

module DataMigrations
  class CreateSettingVariable < Base
    def initialize
      @setting_variable_hash = { question_response_time_in_days: 7 }

      super(1, 'Create setting variable in admin panel')
    end

    private

    def run_migration
      SettingVariable.find_or_create_by(@setting_variable_hash)
    end
  end
end
