ZERO_PERCENT_PAYOUTS_EXPERTS = %w[65c5d580-7ffb-445f-a023-6b2e37ef47ad 784dfce8-a407-438a-b5db-c774181311e9] if Rails.env.production?
ZERO_PERCENT_PAYOUTS_EXPERTS = ['9c045e5e-adfd-44b0-b209-592a62c3c081'] if Rails.env.staging?
ZERO_PERCENT_PAYOUTS_EXPERTS = [] if Rails.env.development? || Rails.env.test?