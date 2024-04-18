class UpdateExpertMappings < ActiveRecord::Migration[6.1]
  def change
    categories_mappings = [
      [1, [42, 44]], # Business - Executive Leadership
      [5, [42, 48]], # Business - Finance
      [32, [42]],    # Business - Franchising
      [3, [42, 48]], # Business - Fundraising / Capital
      [2, [42, 44]], # Business - General Management
      [34, [42, 47]],# Business - Product Development
      [33, [42, 53]],# Business - Real Estate
      [4, [42]],     # Business - Sales / Management
      [13, [42, 47]],# Business - Startup Business Plans
      [14, [43]],    # Celebrity - Author
      [16, [43]],    # Celebrity - Film & TV
      [15, [43]],    # Celebrity - Music Artist
      [18, [43]],    # Celebrity - News Reporter
      [19, [43, 52]],# Celebrity - Political Analyst or Pundit
      [17, [43, 54, 51]], # Celebrity - Social Media Influencer
      [30, [43, 56]],# Celebrity - Sports / Athlete
      [29, [45]],    # Counseling - Addiction
      [28, [45]],    # Counseling - Family
      [21, [46]],    # Crypto - Coins
      [22, [46]],    # Crypto - NFT
      [41, [44]],    # Education - Teacher
      [40, [44]],    # Education - Tutor (K-12)
      [36, [55]],    # Engineering- Chemical Engineer
      [39, [55]],    # Engineering- Civil Engineer
      [38, [55]],    # Engineering- Electrical Engineer
      [35, [55]],    # Engineering- Mechanical Engineer
      [37, [55]],    # Engineering- Software Engineer
      [23, [50]],    # Legal - Contracts
      [27, [50]],    # Legal - Criminal Defense
      [24, [50]],    # Legal - Divorce
      [26, [50]],    # Legal - Immigration
      [12, [44]],    # Life - Coach / Mentor
      [8, [49, 44]], # Life - Health & Fitness
      [11, [48, 44]],# Life - Personal Finance - Wealth
      [31, [44]],    # Life - Work / Life Balance
      [6, [51]],     # Marketing - Marketing & Branding
      [7, [51, 54]], # Marketing - Social Media Expert
      [20, [55]],    # Marketing - Website Development
      [9, [55]],     # Software - Software Development
      [10, [55]]     # Technology - Computer Science
    ]

    categories_mappings.each do |old_id, new_ids|
      begin
        category = Category.find(old_id)
        experts = category.experts
        experts.each do |expert|
          expert.categories.clear
          expert.categories = Category.where(id: new_ids)
          expert.save!
        end
      rescue => ex
        Rails.logger.info "mapping not found"
      end
    end
  end
end
