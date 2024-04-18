class Api::V1::Expert::QuickQuestions::AttachmentsController <
      Api::V1::Expert::QuickQuestionsController
  before_action :set_quick_question, only: %i[show create update]
  before_action :set_attachment, only: %i[show create update]
  skip_before_action :app_version_supported?, only: [:show]

  def create
    unless @quick_question.allow_to_upload_attachment?
      render_not_allow_to_upload
      return
    end

    if @attachment
      @attachment.purge if @attachment.in_bucket?
      @attachment.update!(attachment_params)
    else
      @attachment = @quick_question.create_attachment!(attachment_params)
    end
    @attachment.generate_presigned_url
    render_show_attachment
  end

  def show
    raise ActiveRecord::RecordNotFound unless @attachment

    @attachment.get_attachment_url
    render_show_attachment
  end

  def update
    unless @quick_question.allow_to_upload_attachment?
      render_not_allow_to_upload
      return
    end

    @attachment.update!(update_attachment_params)
    @attachment.get_attachment_url
    render_show_attachment
  end

  private

  def attachment_params
    params.require(:attachment).permit(:file_name, :file_type, :file_size)
  end

  def update_attachment_params
    params.require(:attachment).require(:in_bucket)
    params.require(:attachment).permit(:in_bucket)
  end

  def set_quick_question
    @quick_question = @expert.quick_questions.find(params[:quick_question_id])
  end

  def set_attachment
    @attachment = @quick_question.attachment
  end

  def render_show_attachment
    render 'api/v1/expert/quick_questions/attachment/show'
  end

  def render_not_allow_to_upload
    json_error_response(
      'Can\t attach a file to this quick question', :precondition_failed
    )
  end
end
