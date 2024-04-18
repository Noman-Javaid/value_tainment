class Api::V1::Expert::AvailabilitiesController < Api::V1::Expert::ExpertsController
  before_action :set_availability, only: %i[show update]

  def show
  end

  def update
    @availability.update!(
      Experts::Availabilities::ParamsToAttrsMapper.new(
        availability_params.to_h
      ).call
    )
    render '/api/v1/expert/availabilities/show'
  end

  private

  def availability_params
    params.require(:expert_availability).permit(
      weekdays: [:time_start, :time_end, { days: [] }],
      weekend: [:time_start, :time_end, { days: [] }]
    )
  end

  def set_availability
    @availability = @expert.availability || @expert.build_availability
  end
end
