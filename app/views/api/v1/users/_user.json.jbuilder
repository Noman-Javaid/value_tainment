json.extract! user, :email, :first_name, :last_name, :active, :date_of_birth, :gender,
              :phone_number, :phone, :country_code, :country, :flag_url, :city, :zip_code, :url_picture,
              :allow_notifications, :account_verified, :status
json.two_factor_enabled user.otp_required_for_login?
json.role user.logued_with_role
json.has_both_profiles user.both_profiles?
json.requires_confirmation !user.confirmed?
if profile
  json.expert user.expert, partial: 'api/v1/expert/expert', as: :expert
  json.individual user.individual, partial: 'api/v1/individual/individual',
                                   as: :individual
else
  json.expert user.expert, partial: 'api/v1/expert/expert', as: :expert if user.as_expert?
  if user.as_individual?
    json.individual user.individual, partial: 'api/v1/individual/individual',
                                     as: :individual
  end
end

json.phone user.phone if user.phone.present?
