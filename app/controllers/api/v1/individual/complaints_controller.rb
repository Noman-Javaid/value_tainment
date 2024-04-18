class Api::V1::Individual::ComplaintsController < Api::V1::Individual::IndividualsController
  def create
    complaint_hash = Individuals::Complaints::ParamsToAttrsMapper.new(complaint_params.to_h).call
    @complaint = Complaint.create!(
      complaint_hash.merge({ individual_id: @individual.id })
    )
  end

  private

  def complaint_params
    params.require(:complaint).permit(
      :expert_id, :quick_question_id, :expert_call_id, :content
    )
  end
end
