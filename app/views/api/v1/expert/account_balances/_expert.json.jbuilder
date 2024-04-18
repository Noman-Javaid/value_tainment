json.extract! expert,
              :id,
              :first_name,
              :last_name,
              :url_picture,
              :status
json.set! :total_earnings, expert.total_earnings_to_dollar
json.set! :pending_events, expert.pending_events_to_dollar
json.set! :pending_quick_questions, @pending_quick_questions
