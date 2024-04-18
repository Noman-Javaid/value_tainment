class AddColumnsInExpertTableForRates < ActiveRecord::Migration[6.1]
  def change
    add_column :experts, :quick_question_text_rate, :integer, default: 10
    add_column :experts, :quick_question_video_rate, :integer, default: 20
    add_column :experts, :video_call_rate, :integer, default: 30

    # migrate the data for current records
    # “quick_question_rate”: 50, = “quick_question_text_rate” and “quick_question_video_rate”
    # “one_to_one_video_call_rate”: 5, = “video_call_rate”

    Expert.all.each do |expert|
      expert.update(quick_question_text_rate: expert.quick_question_rate.to_i.positive? ? expert.quick_question_rate.to_i : 10,
                    quick_question_video_rate: expert.quick_question_rate.to_i.positive? ? expert.quick_question_rate.to_i : 20,
                    video_call_rate: expert.one_to_one_video_call_rate.to_i.positive? ? expert.one_to_one_video_call_rate.to_i : 30,)
    end
  end
end
