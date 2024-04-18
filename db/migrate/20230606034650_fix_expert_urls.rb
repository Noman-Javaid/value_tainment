class FixExpertUrls < ActiveRecord::Migration[6.1]
  def change
    Expert.find_each do |expert|
      [:website_url, :linkedin_url, :twitter_url, :instagram_url].each do |field|
        value = expert[field]
        next if value.blank?

        sanitized_url = value.strip
        if sanitized_url.present?
          expert[field] =  "https://#{sanitized_url.split(":").second}"
        end
      end

      expert.save!
    end
  end
end
