# Valuetainment Core Changelog
1.7.6:
  date: 2022-10-13
  changes:
    - Add missing links for various resources in Active Admin
    - update quick question views
    - Add Active Admin improvements
    - update default value of grace period to 1 day
    - [VAL-850] - Add webhook event to update payment method
    - add envar to set up grace period
    - [VAL-849] update transaction historys time addition
    - [VAL-848] fix time addition being set as refunds in transaction history
    - [VAL-844] add test to transfer and refunds jobs
    - Add scopes to alert in admin
    - Add links to Stripe for refund and transfer details view
    - Add links to Stripe related ids in Active Admin
    - [VAL-846] add untransferred and unrefunded state to interaction
    - [VAL-840] add save after transfer and refund execution
    - [VAL-840] fix update transfer and refund execution
    - [VAL-843] update participant events view in admin panel
    - [VAL-840] Make a registration of the succeeded or failed transaction
    - [VAL-843] update participant events view in admin panel
    - [VAL-838] update job for refunds
    - [VAL-837] update job for transfers
    - [VAL-812] update transaction history according to payment upfront flow
    - [VAL-838] update job for refunds
    - [VAL-837] update job for transfers
    - adjust transaction creation with refund service
    - add transaction creator service
    - add is_time_addition boolean to Transaction model
    - [VAL-842] Integrate Stripe Wrapper for Transfers
    - [VAL-841] Integrate Stripe Wrapper for refunds
    - [VAL-834] Implement Stripe Wrapper for Transfers
    - [VAL-839] Add alert model
    - [VAL-834] Implement Stripe Wrapper for Transfers
    - [VAL-833] Implement Stripe Wrapper for Refunds
    - [VAL-811] update account balance according to payment upfront flow
    - update notice message
    - add action item to make refunds in interactions
    - add time addition and participant events in active admin
    - add state machine transition tests
    - update account balance calculator service
    - adjust state machine transitions for the interactions
    - [VAL-836] Add transfer model
    - [VAL-835] Add refund model
    - [CHORE] add time addition info in expert call show view
    - [VAL-809] implement payment creation when a time addition is confirmed by expert
    - [CHORE] update time addition confirm state transition
    - [CHORE] remove stripe payment intent update service
    - [VAL-810] add payment_id to time_addition model
    - [VAL-807] implement payment creation upfront for quick_questions
    - [CHORE] use service payment creator for quick_question creation
    - [CHORE] remove previous payment creation service
    - [VAL-808] add new payment creator service to transfer payment amount to stripe app
    - [VAL-806] implement payment creation upfront for quick_questions
1.7.5:
  date: 2022-09-22
  changes:
    - [VAL-794] fix update grace period of time to zero
1.7.4:
  date: 2022-09-22
  changes:
    - [HOTFIX] update time addition rate formula
1.7.3:
  date: 2022-09-22
  changes:
    - [HOTFIX] update email templates and smtp config
1.7.2:
  date: 2022-08-12
  changes:
    - [VAL-688] set call as incomplete when expert_call does not have payment_id
    - [Chore] add constant for twilio error code
    - [VAL-669] add missing tests for service class
    - [VAL-669] fix webhook service method call
    - [VAL-669] update call finisher job behaviour
    - [VAL-657] update time addition params
    - [VAL-657] update extra time for video calls
    - [Chore] add status attribute to user response
    - [Chore] update silent push notification for android devices in extra time flow
    - [Chore] update expert_call_join expert endpoint response
1.7.1:
  date: 2022-06-06
  changes:
    - [HOTFIX] update two factor code expiration time
1.7.0:
  date: 2022-06-06
  changes:
    - [VAL-579] update user otp generation
    - [VAL-] update_data_migration_call
    - [VAL-] fix bug in email confirmation toggling account_verifield attribute
    - [VAL-579] remove session cookie in two factor login response
    - [VAL-579] update error verbosity in sms service
    - [VAL-579] add two factor info in user response
    - [VAL-554] configure time to response quick questions
    - [VAL-579] validate account using 2FA
    - [VAL-603] fix text in templates
    - [VAL-623] fix start time of immediate calls slots availability
    - [VAL-620] update brand name in mail templates and static pages
    - [VAL-603] add app link redirection in templates
    - [VAL-574] fix typo in mailer templates and static pages
    - [VAL-] fix bug after email confirmation was sent to existing users
    - [VAL-582] add social media links to expert users
    - [VAL-556] add reminders to notifications for upcoming events
    - [VAL-574] add email notification to inform experts users about individual profile creation
    - [VAL-574] create individual profile for existing expert users
    - [VAL-574] add email confirmation to users
    - [VAL-569] New branding name
1.6.3:
  date: 2022-04-05
  changes:
    - [HOTFIX] call to service to end expert call after payment
1.6.2:
  date: 2022-04-05
  changes:
    - [HOTFIX] add ongoing state to transition list in fail event
1.6.1:
  date: 2022-04-04
  changes:
    - [HOTFIX] numericality validation on expert call rates
1.6.0:
  date: 2022-04-04
  changes:
    - [VAL-521] fix silent push content for android devices
    - [VAL-546] reduce time for payment confirm after complete interaction
    - [VAL-535] update after_create callback for complaint model
    - [VAL-521] send silent push when confirm or decline the rescheduled of a call
    - [VAL-532] separate numericality validation with minimums
    - [VAL-535] update edit view in active admin complaints
    - [VAL-532] add validation to expert rates
    - [VAL-521] send silent push notification when event status changes
1.5.0:
  date: 2022-03-16
  changes:
    - [VAL-505] Payment / Signup: add locations outside US
    - [VAL-509] Admin Panel: Configure flags for more territories
    - [VAL-448] add scheduled_call_duration to expert_call
    - [VAL-524] add parameter expert_identify to individual join expert_call
    - [VAL-463] add question details as part of the complaints in active admin
    - [VAL-464] active admin see more details in the Expert status view

1.4.3:
  date: 2022-03-03
  changes:
    - [VAL-512] adjust percentage fee value for payments
1.4.2:
  date: 2022-02-23
  changes:
    - [VAL-497] change current role after profile creation
1.4.1:
  date: 2022-02-22
  changes:
    - [VAL-497] update categories params for expert profile creation
1.4.0:
  date: 2022-02-16
  changes:
    - [VAL-446] include role param in login endpoint
    - [VAL-449] Add voice recording types for mobile
    - [VAL-497] Add endpoint for profile creation
    - Removed exception from docker
    - Added exception to fix db error
    - [VAL-449] add extra mimetypes as valid file types
    - [VAL-449] add pending status as a valid status to upload files
    - [VAL-449-VAL-450] add has_attachment to quickquestion response data
    - [VAL-446] Login expert-individual with same credentials
    - [VAL-449-VAL-450] update add attachment flow without active storage
    - [VAL-450] update url attachment for download
    - [VAL-487] Create endpoint direct upload s3
    - [VAL-450] quick questions download attachment expert
    - [VAL-449] quick question add attachment expert
    - [VAL-] update sign_out response
1.3.0:
  date: 2021-10-04
  changes:
    - [VAL-] update defualt value for allow_notifications as true
    - [VAL-177] update params to pusher notification service
    - [VAL-355] add and configure honey badger gem
    - [VAL-396] update expert_call and quick_question filters in active admin
    - [VAL-22-VAL-35] add enpoints for expert and individual transaction list
    - add requires_reschedule_confirmation status to expert_call list query
    - [VAL-212] add rescheduled expert_call endpoints
    - [VAL-388] update linkedin_url field for expert as optional
    - [VAL-389] mapping missing quick_question status
    - [VAL-177] add endpoint to increase time to video call
    - add rake db migrate on aws environment
1.2.0:
  date: 2021-09-24
  changes:
    - [VAL-305] fix issue for showing passed blocks in current date
    - [VAL-] Fixed time slots available returned in current day
    - [VAL-210] Add user/expert push notifications related to events
    - [VAL-305] improved perrformance issue with individual::experts::availability #show 
    response
    - [VAL-] hide filters in expert_calls and quick_question views
    - [VAL-305] Refactored service to calculate the availability time ranges available for
     an expert in relation to the individual timezone
    - [VAL-] fix DEFAULT_CALL_DURATION env var loading
    - [VAL-] Fixed use of DEFAULT_CALL_DURATION env var
    - [VAL-] changed ExpertCall::DEFAULT_CALL_DURATION to be an env var
    - [VAL-342] follow up feedback by @LSanclemente 
    - [VAL-342] limit max guest in call
    - [VAL-359] relate interaction metadata to payment_intent
    - [VAL-349] handling new stripe webhook events to complete payment flow
    - [VAL-364] picture from http to https
    - [VAL-322] Added endpoint the confirm a guest in a expert_call
    - [VAL-322] Added expert and individual ids to user's info endpoint
    - [VAL-266] create end a video call endpoint
    - including support on admin users, calls, questions
1.1.0:
  date: 2021-09-15
  changes:
    - [VAL-327] expose user type scopes on admin
    - [VAL-314] Added validation for expert_call guest to be active users only
    - [VAL-] avoid list pending questions on completed ones
    - [VAL-313] update scheduled_time_start validation
    - [VAL-325] use expert information to connected account creation
    - [VAL-] fix attached payment intent to expert call
    - [VAL-313] add validation to scheduled_time_start that can not be a passed date
    - [VAL-315-316]  avoid expose questions expired and expert calls without time left
    - [VAL-] update bucket region
    - [VAL-285] fix today date validation

1.0.2:
  date: 2021-09-15
  changes:
    - [VAL-365] update email address in reset password instructions
    - [VAL-366] update expert call rate calculation for extra user
1.0.1:
  date: 2021-09-10
  changes:
    - [VAL-] added fixes to fix seting payment_id in expert_call and fix in transaction_creation for payment related jobs
