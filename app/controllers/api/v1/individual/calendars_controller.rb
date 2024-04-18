class Api::V1::Individual::CalendarsController < Api::V1::Individual::IndividualsController

  def events
    status = params[:status]
    list = if status.present?
             case status
             when 'upcoming'
               # send the list of the upcoming and end time is in future.
               Individual::Calls::UpcomingList.call(@individual)
             when 'past'
               # send the list of the past calls - all other
               Individual::Calls::PassedList.call(@individual)
             else
               Individual::Calls::AllList.call(@individual)
             end
           else
             Individual::Calls::AllList.call(@individual)
           end
    if list.success?
      @events = list.result.page(params[:page]).per(params[:per_page])
    else
      json_error_response(list.errors[:error_message].join(','), :internal_server_error)
    end

  end
end
