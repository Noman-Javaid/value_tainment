class AddDeviseTwoFactorToUsers < ActiveRecord::Migration[6.1]
  def change
    change_table :users, bulk: true do |t|
      t.column :encrypted_otp_secret, :string
      t.column :encrypted_otp_secret_iv, :string
      t.column :encrypted_otp_secret_salt, :string
      t.integer :consumed_timestep
      t.boolean :otp_required_for_login
      # 2FA utils
      t.boolean :two_factor_enabled, default: false
      t.boolean :phone_number_verified, default: false
    end
  end
end
