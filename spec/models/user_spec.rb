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
require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  let(:individual_user) { create(:user) }
  let(:expert_user) { create(:user, :expert) }
  let(:admin_user) { create(:user, :admin) }
  let(:default_user) { create(:user, :default) }
  let(:user_with_profile) { create(:user, :with_profile) }
  let(:user_with_both_profiles) { create(:user, :with_both_profiles) }

  it 'has a valid factory' do
    expect(build(:user)).to be_valid
    expect(user_with_profile).to be_valid
  end

  describe 'attributes' do
    it { is_expected.to have_attribute(:admin) }
  end

  describe 'ActiveModel validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_confirmation_of(:password) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

    describe 'on persisted users' do
      subject { create(:user, :with_profile) }

      it { is_expected.to validate_inclusion_of(:gender).in_array(User::VALID_GENDERS) }
    end
  end

  describe 'validations for a user with profile' do
    context 'when the user is set to update its profile attrs' do
      before { user.start_setting_profile }

      it 'tests for presence' do
        expect(user).not_to be_valid
        expect(user.errors[:zip_code]).to include('can\'t be blank')
        expect(user.errors[:date_of_birth]).to include('can\'t be blank')
        expect(user.errors[:phone_number]).to include('can\'t be blank')
        expect(user.errors[:city]).to include('can\'t be blank')
        expect(user.errors[:country]).to include('can\'t be blank')
      end
    end

    it 'tests for date_of_birth invalid format' do
      user_with_profile.save
      user_with_profile.date_of_birth = '2343ads'
      expect(user_with_profile).not_to be_valid
      expect(user_with_profile.errors[:date_of_birth]).to include('is invalid')
    end

    it 'test for phone_number invalid format' do
      user_with_profile.save
      user_with_profile.phone_number = '2343ads'
      expect(user_with_profile).not_to be_valid
      expect(user_with_profile.errors[:phone_number]).to include('is invalid')
      user_with_profile.phone_number = '234783343'
      expect(user_with_profile).not_to be_valid
      expect(user_with_profile.errors[:phone_number]).to include('is too short (minimum is 10 characters)')
      user_with_profile.phone_number = '123456789012345'
      expect(user_with_profile).not_to be_valid
      expect(user_with_profile.errors[:phone_number]).to include('is too long (maximum is 14 characters)')
    end

    it 'tests for zip_code invalid format' do
      user_with_profile.save
      user_with_profile.zip_code = '2343_ads'
      expect(user_with_profile).not_to be_valid
      user_with_profile.zip_code = '2343--ads'
      expect(user_with_profile).not_to be_valid
      user_with_profile.zip_code = '2343  123'
      expect(user_with_profile).not_to be_valid
      expect(user_with_profile.errors[:zip_code]).to include('is invalid')
    end
  end

  describe 'ActiveRecord associations' do
    it { is_expected.to have_one(:expert).dependent(:destroy) }
    it { is_expected.to have_one(:individual).dependent(:destroy) }
    it { is_expected.to have_one(:device).dependent(:destroy) }
  end

  describe 'scopes' do
    let(:active_users) { create_list(:user, 2) }
    let(:inactive_users) { create_list(:user, 2, active: false) }
    let(:pending_to_delete_users) { create_list(:user, 2, pending_to_delete: true) }

    describe '.active' do
      it 'returns only the active users' do
        expect(described_class.active).to contain_exactly(*active_users)
      end
    end

    describe '.pending_for_deletion' do
      it 'returns only the users pending to delete' do
        expect(described_class.pending_for_deletion).to(
          contain_exactly(*pending_to_delete_users)
        )
      end
    end

    describe '.by_role' do
      context 'with "admin"' do
        it 'returns a user list containing only the admin' do
          expect(described_class.by_role('admin')).to contain_exactly(admin_user)
        end
      end

      context 'with "expert"' do
        it 'returns a user list containing only the expert' do
          expect(described_class.by_role('expert')).to contain_exactly(expert_user)
        end
      end

      context 'with "individual"' do
        it 'returns a user list containing only the individual' do
          expect(described_class.by_role('individual')).to contain_exactly(individual_user)
        end
      end

      context 'with an invalid argument' do
        it 'returns an empty user list' do
          expect(described_class.by_role('')).to be_empty
        end
      end
    end

    describe 'without any scope' do
      it 'returns all the users' do
        expect(described_class.all).to contain_exactly(*(active_users + inactive_users))
      end
    end
  end

  describe 'public instance methods' do
    describe 'responds to its methods' do
      it { is_expected.to respond_to(:name) }
      it { is_expected.to respond_to(:expert?) }
      it { is_expected.to respond_to(:individual?) }
      it { is_expected.to respond_to(:admin?) }
      it { is_expected.to respond_to(:role) }
      it { is_expected.to respond_to(:logued_with_role) }
      it { is_expected.to respond_to(:regenerate_two_factor_secret!) }
      it { is_expected.to respond_to(:enable_two_factor!) }
      it { is_expected.to respond_to(:disable_two_factor!) }
      it { is_expected.to respond_to(:two_factor_backup_codes_generated?) }
      it { is_expected.to respond_to(:validate_otp_backup_code) }
    end

    describe 'executes methods correctly' do
      describe '#name' do
        it 'returns the full name of the user' do
          expect(user.name).to eq("#{user.first_name} #{user.last_name}")
        end
      end

      describe '#expert?' do
        context 'when the user is an expert' do
          it 'is an expert' do
            expect(expert_user).to be_expert
          end
        end

        context 'when the user is an individual' do
          it 'is not an expert' do
            expect(individual_user).not_to be_expert
          end
        end

        context 'when the user is an admin' do
          it 'is not an expert' do
            expect(admin_user).not_to be_expert
          end
        end
      end

      describe '#individual?' do
        context 'when the user is an individual' do
          it 'is an individual' do
            expect(individual_user).to be_individual
          end
        end

        context 'when the user is an expert' do
          it 'is not an individual' do
            expect(expert_user).not_to be_individual
          end
        end

        context 'when the user is an admin' do
          it 'is not an individual' do
            expect(admin_user).not_to be_individual
          end
        end
      end

      describe '#admin?' do
        context 'when the user is an admin' do
          it 'is an admin' do
            expect(admin_user).to be_admin
          end
        end

        context 'when the user is an individual' do
          it 'is not an admin' do
            expect(individual_user).not_to be_admin
          end
        end

        context 'when the user is an expert' do
          it 'is not an admin' do
            expect(expert_user).not_to be_admin
          end
        end
      end

      describe '#change_current_role!' do
        context 'when the user has role as individual' do
          context 'when has both profiles' do
            before do
              user_with_both_profiles.update(current_role: 'as_individual')
              user_with_both_profiles.change_current_role!
            end

            it 'is now an expert' do
              expect(user_with_both_profiles).to be_as_expert
            end
          end

          context 'when does not have both profiles' do
            before { individual_user.change_current_role! }

            it 'is not an expert' do
              expect(individual_user).not_to be_as_expert
            end
          end
        end

        context 'when the user has role as expert' do
          context 'when has both profiles' do
            before do
              user_with_both_profiles.update(current_role: 'as_expert')
              user_with_both_profiles.change_current_role!
            end

            it 'is now an individual' do
              expect(user_with_both_profiles).to be_as_individual
            end
          end

          context 'when does not have both profiles' do
            before { expert_user.change_current_role! }

            it 'is not an individual' do
              expect(expert_user).not_to be_as_individual
            end
          end
        end

        context 'when the user is a default' do
          before { default_user.change_current_role! }

          it 'still a default' do
            expect(default_user).to be_as_default
          end
        end
      end

      describe '#both_profiles?' do
        context 'when user has both profiles' do
          it { expect(user_with_both_profiles).to be_both_profiles }
        end

        context 'when user do not have both profiles' do
          it { expect(expert_user).not_to be_both_profiles }
        end
      end

      describe '#role' do
        context 'when the user is an admin' do
          it 'returns "admin"' do
            expect(admin_user.role).to eq('admin')
          end
        end

        context 'when the user is an individual' do
          it 'returns "individual"' do
            expect(individual_user.role).to eq('individual')
          end
        end

        context 'when the user is an expert' do
          it 'returns "expert"' do
            expect(expert_user.role).to eq('expert')
          end
        end

        context 'when the user is a default user' do
          it 'returns "default"' do
            expect(default_user.role).to eq('default')
          end
        end
      end

      describe '#logued_with_role' do
        context 'when the user has current_role as_expert' do
          it 'returns "expert"' do
            expect(expert_user.role).to eq('expert')
          end
        end

        context 'when the user has current_role as_individual' do
          it 'returns "individual"' do
            expect(individual_user.role).to eq('individual')
          end
        end

        context 'when the user has current_role as_admin' do
          it 'returns "admin"' do
            expect(admin_user.role).to eq('admin')
          end
        end
      end

      describe '#regenerate_two_factor_secret!' do
        before { individual_user.regenerate_two_factor_secret! }

        it 'has otp_secret present' do
          expect(individual_user.otp_secret).to be_present
        end

        it 'generates current_otp' do
          expect(individual_user.current_otp).to be_present
        end
      end

      describe '#enable_two_factor!' do
        before { individual_user.enable_two_factor! }

        it 'otp_required_for_login returns true' do
          expect(individual_user.otp_required_for_login).to be_truthy
        end
      end

      describe '#disable_two_factor!' do
        before { individual_user.disable_two_factor! }

        it 'otp_required_for_login returns false' do
          expect(individual_user.otp_required_for_login).to be_falsey
        end

        it 'otp_secret returns nil' do
          expect(individual_user.otp_secret).to be_nil
        end

        it 'otp_backup_codes returns nil' do
          expect(individual_user.otp_backup_codes).to be_nil
        end
      end

      describe '#two_factor_backup_codes_generated?' do
        context 'when the otp_backup_codes has not been generated' do
          it 'returns false' do
            expect(individual_user).not_to be_two_factor_backup_codes_generated
          end
        end

        context 'when the otp_backup_codes has been generated' do
          before { individual_user.generate_otp_backup_codes! }

          it 'returns true' do
            expect(individual_user).to be_two_factor_backup_codes_generated
          end
        end
      end

      describe '#validate_otp_backup_code' do
        context 'when the otp_backup_codes has not been generated' do
          let(:code) { 'test_code' }

          it 'returns false' do
            expect(individual_user.validate_otp_backup_code(code)).to be_falsey
          end
        end

        context 'when the otp_backup_codes has been generated' do
          let(:code) { individual_user.generate_otp_backup_codes!.first }

          it 'returns true' do
            expect(individual_user.validate_otp_backup_code(code)).to be_truthy
          end
        end
      end
    end
  end

  describe 'public class methods' do
    describe 'responds to its methods' do
      it { expect(described_class).to respond_to(:search_by_name) }
    end

    describe 'executes methods correctly' do
      describe '.search_by_name' do
        let!(:individual_user1) { create(:user, :individual, first_name: 'Individual 1', last_name: 'User') }
        let!(:individual_user2) { create(:user, :individual, first_name: 'Individual 2', last_name: 'User') }
        let!(:expert_user1) { create(:user, :expert, first_name: 'Expert 1', last_name: 'User') }
        let!(:expert_user2) { create(:user, :expert, first_name: 'Expert 2', last_name: 'User') }
        let!(:admin_user1) { create(:user, :admin, first_name: 'Admin 1', last_name: 'User') }
        let!(:admin_user2) { create(:user, :admin, first_name: 'Admin 2', last_name: 'User') }
        let!(:all_users) { described_class.all }

        context 'when searched for "Individual"' do
          it 'returns only the individual users' do
            expect(described_class.search_by_name('Individual')).to contain_exactly(individual_user1, individual_user2)
          end
        end

        context 'when searched for "INDIVIDUAL"' do
          it 'returns only the individual users' do
            expect(described_class.search_by_name('INDIVIDUAL')).to contain_exactly(individual_user1, individual_user2)
          end
        end

        context 'when searched for "individual"' do
          it 'returns only the individual users' do
            expect(described_class.search_by_name('individual')).to contain_exactly(individual_user1, individual_user2)
          end
        end

        context 'when searched for "individual user"' do
          it 'returns only the individual users' do
            expect(described_class.search_by_name('individual user')).to contain_exactly(individual_user1, individual_user2)
          end
        end

        context 'when searched for "user individual"' do
          it 'returns only the individual users' do
            expect(described_class.search_by_name('user individual')).to contain_exactly(individual_user1, individual_user2)
          end
        end

        context 'when searched for "individual user 1"' do
          it 'returns only the individual user 1' do
            expect(described_class.search_by_name('individual user 1')).to contain_exactly(individual_user1)
          end
        end

        context 'when searched for "1"' do
          it 'returns only the users that contains "1" in the name' do
            expect(described_class.search_by_name('1')).to contain_exactly(individual_user1, expert_user1, admin_user1)
          end
        end

        context 'when searched for "Expert User"' do
          it 'returns only the expert users' do
            expect(described_class.search_by_name('Expert User')).to contain_exactly(expert_user1, expert_user2)
          end
        end

        context 'when searched for "Admin User"' do
          it 'returns only the admin users' do
            expect(described_class.search_by_name('Admin User')).to contain_exactly(admin_user1, admin_user2)
          end
        end

        context 'when searched for ""' do
          it 'returns an empty list' do
            expect(described_class.search_by_name('')).to be_empty
          end
        end

        context 'when searched for "something that does not fit any user"' do
          it 'returns an empty list' do
            expect(described_class.search_by_name('something that does not fit any user')).to be_empty
          end
        end

        context 'when searched for "user"' do
          it 'returns all the users' do
            expect(described_class.search_by_name('user')).to contain_exactly(*all_users)
          end
        end
      end

      describe '.valid_role?' do
        context 'when invalid role is used' do
          let(:role) { 'default' }

          it { expect(described_class).not_to be_valid_role(role) }
        end

        context 'when valid role is used' do
          context 'with expert' do
            let(:role) { 'expert' }

            it { expect(described_class).to be_valid_role(role) }
          end

          context 'with individual' do
            let(:role) { 'individual' }

            it { expect(described_class).to be_valid_role(role) }
          end
        end
      end

      describe '.roles' do
        it 'returns all roles' do
          expect(described_class.roles).to match_array(
            described_class::ADMIN_ROLES + described_class::APP_ROLES +
            described_class::AUXILIAR_ROLES
          )
        end
      end
    end
  end
end
