# Create Admin user
admin_user = {
  email: 'admin@valuetainment.com',
  admin: true,
  first_name: 'Admin',
  last_name: 'User',
  password: 'DJCEsLbJvpL79UXrnEkL',
  password_confirmation: 'DJCEsLbJvpL79UXrnEkL',
  confirmed_at: DateTime.now
}
User.create_or_find_by(admin_user)

# Add territories info
return unless defined? Territory

territories = [
  { name: 'Australia', alpha2_code: 'AU', phone_code: '61' },
  { name: 'Austria', alpha2_code: 'AT', phone_code: '43' },
  { name: 'Belgium', alpha2_code: 'BE', phone_code: '32' },
  { name: 'Brazil', alpha2_code: 'BR', phone_code: '55' },
  { name: 'Canada', alpha2_code: 'CA', phone_code: '1' },
  { name: 'Czech Republic', alpha2_code: 'CZ', phone_code: '420' },
  { name: 'Denmark', alpha2_code: 'DK', phone_code: '45' },
  { name: 'Finland', alpha2_code: 'FI', phone_code: '358' },
  { name: 'France', alpha2_code: 'FR', phone_code: '33' },
  { name: 'Germany', alpha2_code: 'DE', phone_code: '49' },
  { name: 'Greece', alpha2_code: 'GR', phone_code: '30' },
  { name: 'Hong Kong SAR China', alpha2_code: 'HK', phone_code: '852' },
  { name: 'Hungary', alpha2_code: 'HU', phone_code: '36' },
  { name: 'Ireland', alpha2_code: 'IE', phone_code: '353' },
  { name: 'Italy', alpha2_code: 'IT', phone_code: '39' },
  { name: 'Japan', alpha2_code: 'JP', phone_code: '81' },
  { name: 'Luxembourg', alpha2_code: 'LU', phone_code: '352' },
  { name: 'Mexico', alpha2_code: 'MX', phone_code: '52' },
  { name: 'Netherlands', alpha2_code: 'NL', phone_code: '31' },
  { name: 'New Zealand', alpha2_code: 'NZ', phone_code: '64' },
  { name: 'Norway', alpha2_code: 'NO', phone_code: '47' },
  { name: 'Poland', alpha2_code: 'PL', phone_code: '48' },
  { name: 'Portugal', alpha2_code: 'PT', phone_code: '351' },
  { name: 'Spain', alpha2_code: 'ES', phone_code: '34' },
  { name: 'Sweden', alpha2_code: 'SE', phone_code: '46' },
  { name: 'Switzerland', alpha2_code: 'CH', phone_code: '41' },
  { name: 'United Kingdom', alpha2_code: 'GB', phone_code: '44' },
  { name: 'United States', alpha2_code: 'US', phone_code: '1' }
]

territories.each do |territory|
  country = Territory.find_by(territory)
  country ||= Territory.create!(territory)
  next if country.flag.attached?

  filename = "#{country.alpha2_code}.png"
  country.flag.attach(
    io: File.open(Rails.root.join('app/assets/images/territory_flags', filename)),
    filename: filename
  )
end

# --------------
# | Categories |
# ==============
category = Category.create(
  name: 'Category Name',
  description: 'Category long description'
)

# Skip Set Stripe Customer Callback
Individual.skip_callback(:commit, :after, :set_stripe_customer)

# --------------
# | Individual |
# ==============
user_individual = User.create!(
  email: 'individual@example.com',
  password: 'DJCEsLbJvpL79UXrnEkL',
  password_confirmation: 'DJCEsLbJvpL79UXrnEkL',
  admin: false,
  first_name: 'John',
  last_name: 'Doe',
  role: 'individual',
  active: true,
  confirmed_at: DateTime.now,
  date_of_birth: '19990405',
  gender: 'male',
  phone_number: '345392985022',
  city: 'New York',
  zip_code: '1653',
  country: 'US',
  status: User::STATE_PROFILE_SET
)

individual = Individual.create!(
  username: 'johndoe',
  user: user_individual,
  stripe_customer_id: 'cus_MNTUdoEgYSCRcm',
  has_stripe_payment_method: true
)

# --------------
# |   Expert   |
# ==============
user_expert = User.create(
  email: 'expert@example.com',
  password: 'DJCEsLbJvpL79UXrnEkL',
  password_confirmation: 'DJCEsLbJvpL79UXrnEkL',
  admin: false,
  first_name: 'Jane',
  last_name: 'Doe',
  role: 'expert',
  active: true,
  confirmed_at: DateTime.now,
  date_of_birth: '19990405',
  gender: 'male',
  phone_number: '345392985022',
  city: 'New York',
  zip_code: '1653',
  country: 'US',
  status: User::STATE_PROFILE_SET
)

expert = Expert.create(
  user: user_expert,
  biography: 'Business user with knowledge in Economics',
  website_url: 'www.user_web.com',
  linkedin_url: 'www.linkedin.com/user_profile',
  instagram_url: 'www.instagram.com/user_profile',
  twitter_url: 'www.twitter.com/user_profile',
  quick_question_rate: 50,
  one_to_one_video_call_rate: 5,
  one_to_five_video_call_rate: 10,
  extra_user_rate: 5,
  stripe_account_id: 'acct_1L08qJPSjNadTzDs',
  stripe_account_set: true,
  can_receive_stripe_transfers: true,
  status: 1
)

# -----------------
# |   Video Call  |
# =================
expert_call = ExpertCall.create(
  expert: expert,
  individual: individual,
  category: category,
  title: 'Call with Jane',
  description: 'Video Call with Jane Doe',
  call_type: '1-1',
  scheduled_time_start: 1.day.from_now,
  stripe_payment_method_id: 'pm_sjlkf023jr',
  call_status: 'scheduled'
)

# ---------------------
# |   Quick Question  |
# =====================
quick_question = QuickQuestion.create(
  expert: expert,
  individual: individual,
  category: category,
  question: 'Call with Jane?',
  description: 'How is it going Jane Doe?',
  stripe_payment_method_id: 'pm_sjlkf023jr',
  answer: 'Long answer content',
  answer_date: Time.zone.now,
  payment_status: 'succeeded',
  status: 'answered'
)

# ---------------------
# |   Time Addition   |
# =====================
time_addition = TimeAddition.create(
  expert_call: expert_call,
  rate: 50,
  duration: 1200,
  payment_status: 'succeeded',
  payment_id: 'pm_sjlkf023jr'
)

# ---------------
# |   Refunds   |
# ===============
Refund.create(
  refundable: expert_call,
  payment_intent_id_ext: 'pi_3KXBl7A3xt8sfcfk0Qy89Rip',
  refund_id_ext: 're_3KXBl7A3xt8sfcfk0TdGUXXH',
  status: 'succeeded',
  amount: 5_000,
  refund_metadata: { id: 're_3KXBl7A3xt8sfcfk0TdGUXXH' }
)

Refund.create(
  refundable: quick_question,
  payment_intent_id_ext: 'pi_3KXBl7A3xt8sfcfk0Qy89Rip',
  refund_id_ext: 're_3KXBl7A3xt8sfcfk0TdGUXXH',
  status: 'succeeded',
  amount: 5_000,
  refund_metadata: { id: 're_3KXBl7A3xt8sfcfk0TdGUXXH' }
)

Refund.create(
  refundable: time_addition,
  payment_intent_id_ext: 'pi_3KXBl7A3xt8sfcfk0Qy89Rip',
  refund_id_ext: 're_3KXBl7A3xt8sfcfk0TdGUXXH',
  status: 'succeeded',
  amount: 5_000,
  refund_metadata: { id: 're_3KXBl7A3xt8sfcfk0TdGUXXH' }
)

# ----------------
# |   Transfers  |
# ================
Transfer.create(
  transferable: expert_call,
  amount: 5_000,
  balance_transaction_id_ext: 'txn_1JUhvwA3xt8sfcfk1vnVsI01',
  destination_account_id_ext: 'acct_1L06fcAcEzQh1MY0',
  destination_payment_id_ext: 'py_1LpyY6AcEzQh1MY0K1zjAIzB',
  reversed: false,
  transfer_id_ext: 'tr_1LpyY6A3xt8sfcfkdc3eMXFE',
  transfer_metadata: { id: 'tr_1LpyY6A3xt8sfcfkdc3eMXFE' }
)

Transfer.create(
  transferable: quick_question,
  amount: 5_000,
  balance_transaction_id_ext: 'txn_1JUhvwA3xt8sfcfk1vnVsI01',
  destination_account_id_ext: 'acct_1L06fcAcEzQh1MY0',
  destination_payment_id_ext: 'py_1LpyY6AcEzQh1MY0K1zjAIzB',
  reversed: false,
  transfer_id_ext: 'tr_1LpyY6A3xt8sfcfkdc3eMXFE',
  transfer_metadata: { id: 'tr_1LpyY6A3xt8sfcfkdc3eMXFE' }
)

Transfer.create(
  transferable: time_addition,
  amount: 5_000,
  balance_transaction_id_ext: 'txn_1JUhvwA3xt8sfcfk1vnVsI01',
  destination_account_id_ext: 'acct_1L06fcAcEzQh1MY0',
  destination_payment_id_ext: 'py_1LpyY6AcEzQh1MY0K1zjAIzB',
  reversed: false,
  transfer_id_ext: 'tr_1LpyY6A3xt8sfcfkdc3eMXFE',
  transfer_metadata: { id: 'tr_1LpyY6A3xt8sfcfkdc3eMXFE' }
)

# -------------
# |   Alerts  |
# =============
Alert.create(
  alert_type: :refund,
  alertable: expert_call,
  message: "Error with refund for expert call #{expert_call.id}",
  note: 'Some note left'
)

Alert.create(
  alert_type: :transfer,
  alertable: quick_question,
  message: "Error with refund for quick question #{quick_question.id}",
  note: 'Some note left'
)

Alert.create(
  alert_type: :refund,
  alertable: time_addition,
  message: "Error with refund for time addition #{time_addition.id}",
  note: 'Some note left'
)

# ------------------------
# |  Participant Events  |
# ========================
ParticipantEvent.create(
  duration: 50,
  event_datetime: Time.zone.now,
  event_name: 'participant-connected',
  expert: true,
  initial: true,
  expert_call: expert_call,
  participant_id: expert.id
)

ParticipantEvent.create(
  duration: 50,
  event_datetime: Time.zone.now,
  event_name: 'participant-connected',
  expert: false,
  initial: false,
  expert_call: expert_call,
  participant_id: individual.id
)

# ------------------------
# |  Expert Interaction  |
# ========================
expert_call_interaction = ExpertInteraction.create(
  expert: expert,
  interaction: expert_call
)

quick_question_interaction = ExpertInteraction.create(
  expert: expert,
  interaction: quick_question
)

# -------------------
# |   Complaints    |
# ===================
Complaint.create(
  individual: individual,
  expert: expert,
  status: 'requires_verification',
  content: 'Complaint message',
  expert_interaction: expert_call_interaction
)

Complaint.create(
  individual: individual,
  expert: expert,
  status: 'requires_verification',
  content: 'Complaint message',
  expert_interaction: quick_question_interaction
)

Complaint.create(
  individual: individual,
  expert: expert,
  status: 'requires_verification',
  content: 'Complaint message'
)

# -------------------
# |  Transactions   |
# ===================
Transaction.create(
  individual: individual,
  expert: expert,
  expert_interaction: quick_question_interaction,
  amount: 5_000,
  charge_type: Transaction::CHARGE_TYPE_CANCELATION,
  stripe_transaction_id: 're_xxxxx'
)

Transaction.create(
  individual: individual,
  expert: expert,
  expert_interaction: expert_call_interaction,
  amount: 5_000,
  charge_type: Transaction::CHARGE_TYPE_CONFIRMATION,
  stripe_transaction_id: 'pi_xxxxx'
)

# Set set stripe customer callback back
Individual.set_callback(:commit, :after, :set_stripe_customer)
