class FixUrlsInExperts < ActiveRecord::Migration[6.1]
  def up
    Expert.find_each do |expert|
      [:website_url, :linkedin_url, :twitter_url, :instagram_url].each do |field|
        value = expert[field]
        next if value.blank?

        sanitized_url = value.strip

        uri = URI.parse(sanitized_url)
        uri.scheme = 'https' if uri.scheme.blank? || uri.scheme == 'http'
        uri.host = "www.#{uri.host}" if uri.host.present? && !uri.host.start_with?('www.')

        expert[field] = uri.to_s
      end

      expert.save!
    end
  end

  def down
    # Reverting this migration is not supported as it modifies data.
    raise ActiveRecord::IrreversibleMigration
  end
end
