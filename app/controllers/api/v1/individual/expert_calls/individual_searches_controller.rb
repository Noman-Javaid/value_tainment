# frozen_string_literal: true

# Related to APi requests
module Api
  # V1
  module V1
    # related to indivudual's endpoints
    module Individual
      # related to the handle of expert_calls
      module ExpertCalls
        # realted to the search of individuals to assign them to a call
        class IndividualSearchesController < Api::V1::Individual::IndividualsController
          # paginted search of individuals
          def show
            @users = ::User.active.joins(:individual)
                           .where.not(id: current_user.id)
                           .search_by_name_and_email(
                             individual_search_params[:search_criteria]
                           )
                           .page(params[:page]).per(params[:per_page])
                           .includes(:picture_attachment)
          end

          private

          def individual_search_params
            params.require(:individual_search).permit(:search_criteria)
          end
        end
      end
    end
  end
end
