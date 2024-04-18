# == Schema Information
#
# Table name: users
#
#  id                            :bigint           not null, primary key
#  account_deletion_requested_at :datetime
#  account_verified              :boolean          default(FALSE)
#  active                        :boolean          default(TRUE)
#  admin                         :boolean          default(FALSE)
#  allow_notifications           :boolean          default(FALSE)
#  city                          :string
#  confirmation_sent_at          :datetime
#  confirmation_token            :string
#  confirmed_at                  :datetime
#  consumed_timestep             :integer
#  country                       :string
#  country_code                  :string           default("+1")
#  current_role                  :integer          default("as_individual"), not null
#  date_of_birth                 :date
#  email                         :string           default(""), not null
#  encrypted_otp_secret          :string
#  encrypted_otp_secret_iv       :string
#  encrypted_otp_secret_salt     :string
#  encrypted_password            :string           default(""), not null
#  first_name                    :string
#  gender                        :string
#  is_default                    :boolean          default(FALSE)
#  last_name                     :string
#  otp_backup_codes              :string           is an Array
#  otp_required_for_login        :boolean
#  pending_to_delete             :boolean          default(FALSE)
#  phone                         :string
#  phone_number                  :string
#  phone_number_verified         :boolean          default(FALSE)
#  remember_created_at           :datetime
#  reset_password_sent_at        :datetime
#  reset_password_token          :string
#  status                        :string           default("registered")
#  unconfirmed_email             :string
#  zip_code                      :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  users_name_idx                       (to_tsvector('simple'::regconfig, (((first_name)::text || ' '::text) || (last_name)::text))) USING gin
#
class AdminUser < User
end
