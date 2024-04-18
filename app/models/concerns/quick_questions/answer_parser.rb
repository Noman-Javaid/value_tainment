module QuickQuestions
  # state machine for quick_questions
  module AnswerParser
    extend ActiveSupport::Concern

    included do

      def parse_answer(answer_text)
        answer = answer_text.dup
        begin
          urls = answer.scan(/\S+[.]\S+/xms) # Not using the URI.extract here as we want www scheme as well.
          urls.each do |url|
            answer.gsub!(url, "[#{url}](#{url})")
          end
          answer
        rescue Exception => ex
          Rails.logger.error "Unable to parsed the answer text. #{answer_text} due to #{ex}"
          answer_text
        end
      end
    end
  end
end

