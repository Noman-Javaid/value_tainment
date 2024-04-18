class CreateUnaccentExtension < ActiveRecord::Migration[6.1]
  def up
    execute 'CREATE EXTENSION IF NOT EXISTS unaccent'
  end
end
