namespace :categories do
  task populate: :environment do
    %w[Culture Finances Lawyer Science Technology Business].each do |name|
      Category.create!(
        name: name,
        description: "Description of #{name}"
      )
    end
  end
end
