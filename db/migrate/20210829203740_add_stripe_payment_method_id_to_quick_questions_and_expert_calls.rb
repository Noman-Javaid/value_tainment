class AddStripePaymentMethodIdToQuickQuestionsAndExpertCalls < ActiveRecord::Migration[6.1]
  def change
    add_column :expert_calls, :stripe_payment_method_id, :string
    add_column :quick_questions, :stripe_payment_method_id, :string
  end
end
