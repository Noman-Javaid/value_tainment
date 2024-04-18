class Api::V1::Individual::Experts::AvailabilitiesController < Api::V1::Individual::ExpertsController
  before_action :set_expert, :set_availability, :check_valid_call_duration, only: %i[show]

  def show
    render json: {
      status: :success,
      data: {
        expert_availability:
          Availabilities::TimeSlotsCalculator.new(
            @availability, @individual, params[:date_initial], params[:date_end],
            params[:call_duration]&.to_i
          ).execute
      }
    }
  end

  private

  def set_availability
    @availability = @expert.availability
  end

  def set_expert
    @expert = Expert.find(params[:expert_id])
  end
end
