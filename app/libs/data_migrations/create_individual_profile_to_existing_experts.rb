# frozen_string_literal: true

require_relative 'base'

module DataMigrations
  class CreateIndividualProfileToExistingExperts < Base
    def initialize
      @users = User.joins(:expert).where.missing(:individual)

      super(@users.count, 'Create individual profile to existing experts')
    end

    private

    def run_migration
      ActiveRecord::Base.transaction do
        @users.each(&:create_individual!)
      end
    end
  end
end
