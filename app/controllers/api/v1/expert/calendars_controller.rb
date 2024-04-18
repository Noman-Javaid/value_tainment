class Api::V1::Expert::CalendarsController < Api::V1::Expert::ExpertsController

  def events
    status = params[:status]
    list = if status.present?
             case status
             when 'pending'
               # send the pending calls - not accepted or rejected and not expired
               Expert::Calls::PendingList.call(@expert)
             when 'upcoming'
               # send the list of the upcoming calls - accepted and start time is in future.
               Expert::Calls::UpcomingList.call(@expert)
             when 'past'
               # send the list of the past calls - all other
               Expert::Calls::PassedList.call(@expert)
             else
               Expert::Calls::AllList.call(@expert)
             end
           else
             Expert::Calls::AllList.call(@expert)
           end
    if list.success?
      @events = list.result.page(params[:page]).per(params[:per_page])
    else
      json_error_response(list.errors[:error_message].join(','), :internal_server_error)
    end

  end
end
