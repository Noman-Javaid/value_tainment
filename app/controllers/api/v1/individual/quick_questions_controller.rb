class Api::V1::Individual::QuickQuestionsController < Api::V1::Individual::IndividualsController
  def index
    @quick_questions = @individual.quick_questions.includes(
      :category, expert: { user: :picture_attachment }
    )
    if params[:query].present?
      @quick_questions = @quick_questions.ransack(params[:query]).result
    elsif params[:completed] == 'true'
      @quick_questions = @quick_questions.answered_question_list
    end
    # sort with created at
    @quick_questions = @quick_questions.most_recent
                                       .page(params[:page])
                                       .per(params[:per_page])
  end

  def show
    @quick_question = @individual.quick_questions.find(params[:id])
  end

  def create
    payment = nil
    ActiveRecord::Base.transaction do
      @quick_question = @individual.quick_questions.create!(question_params)
      payment = Stripes::Payments::InteractionPaymentHandler.call(@quick_question)
      raise Stripe::APIConnectionError, payment.api_error if payment.respond_to?(:api_error)
      raise Stripe::StripeError, payment.error if payment.respond_to?(:error)
      @client_secret = payment[:client_secret]
      @quick_question.update!(payment_id: payment.id, payment_status: payment.status)
    end

    Transactions::Create.call(@quick_question, payment, false)
    notifier = Notifications::Experts::QuickQuestionNotifier.new(@quick_question)
    notifier.new_question
    notifier.about_to_expire
    Notifications::Individuals::QuickQuestionNotifier.new(@quick_question).new_question
  end

  private

  def question_params
    params.require(:quick_question).permit(
      :expert_id, :question, :description, :category_id, :stripe_payment_method_id,
      :answer_type
    )
  end
end
