class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.invert_where
    spawn.tap do |relation|
      relation.where_clause = relation.where_clause.invert
    end
  end
end
