# frozen_string_literal: true

# Require your files for each specific data migration
# Please add a comment as to when the migration is going
# to be run in staging/production.
# Example:
# # Release 2021-02-19
require_relative 'data_migrations/create_individual_profile_to_existing_experts'

module DataMigrations
  class << self
    # Returns the total count of things migrated
    def migrate!
      CreateIndividualProfileToExistingExperts.new.run!
      CreateSettingVariable.new.run!
      AddResponseTimeToQuickQuestions.new.run!
      CreateAnonymousDefaultUser.new.run!
    end
  end
end
