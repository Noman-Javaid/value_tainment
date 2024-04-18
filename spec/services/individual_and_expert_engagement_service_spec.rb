require 'rails_helper'

describe IndividualAndExpertEngagementService do
  let(:subject) { described_class.new(individual, expert).call }

  context "with data" do
    let(:expert_call) { create(:expert_call, :finished) }
    let(:individual) { expert_call.individual }
    let(:expert) { expert_call.expert }
    let(:metrics) do
      {
        completed_calls: 1,
        answered_questions: 1
      }
    end

    before do
      create(:quick_question, :answered, individual: individual, expert: expert)
    end

    it "return the engagement metrics" do
      expect(subject).to eql metrics
    end
  end
end
