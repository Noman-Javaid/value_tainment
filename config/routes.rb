require 'sidekiq/web'
require 'sidekiq-scheduler'
require 'sidekiq-scheduler/web'
Rails.application.routes.draw do
  Healthcheck.routes(self)
  devise_for :admin_user, ActiveAdmin::Devise.config
  devise_for :users, controllers: { passwords: 'passwords', confirmations: 'confirmations' }
  ActiveAdmin.routes(self)
  root to: 'admin/dashboard#index'
  get '/link_account', to: redirect('link_account.html')
  get '/welcome_back', to: redirect('welcome_back.html')
  get '/success_confirmation', to: redirect('success_confirmation.html')
  get '/welcome_expert', to: redirect('welcome_expert.html')
  mount Sidekiq::Web => '/sidekiq'

  devise_scope :admin_user do
    get 'admin/logout', to: 'active_admin/devise/sessions#destroy'
  end

  defaults format: :json do
    namespace :api do
      namespace :v1 do
        devise_scope :user do
          post 'sign_in', to: 'auth/sessions#create'
          delete 'sign_out', to: 'auth/sessions#destroy'
          post 'sign_up', to: 'auth/registrations#create'
          post 'password', to: 'auth/passwords#create'
        end

        post :stripe_webhooks, to: 'stripe_webhooks#receive'
        post :twilio_webhooks, to: 'twilio_webhooks#receive'
        post :email_confirmation, to: 'email_confirmation#send_instructions'

        resource :utils do
          member do
            post :submit_contact_form
          end
        end

        namespace :web do
          resources :experts, only: [:index, :show], defaults: { format: :json } do
            member do
              get :reviews
            end

            collection do
              get :rates
              get :featured
            end
          end
        end

        resource :user, only: %i[show]

        namespace :user do
          namespace :profile_picture do
            patch :update
          end
          resource :change_profile, only: %i[update], to: 'change_profile#update'
          resource :allow_notifications, only: %i[update]
          resource :devices, only: %i[update], to: 'devices/devices#update'
          resource :send_email_confirmation, only: %i[show], to: 'send_email_confirmation#show'
          resource :two_factor_settings, only: %i[new create destroy]
          resource :accounts, only: %i[destroy]
        end

        namespace :expert do
          resource :user, only: %i[update] do
            member do
              put :update
              patch :update
            end
          end

          resources :private_chats, only: [:index, :show] do
            scope module: :private_chats do
              resource :attachment, only: %i[show create update]
            end
            post 'message', to: 'private_chats#message', on: :member, as: :write_message_on_private_chat
            put 'read', to: 'private_chats#read_messages', on: :member, as: :read_message_on_private_chat
          end

          resource :profiles, only: %i[create]
          get 'reviews', to: 'reviews#index'
          resources :quick_questions, only: %i[index show update] do
            scope module: 'quick_questions' do
              resource :attachment, only: %i[show create update]
            end
          end

          resource :account_balance, only: %i[show]
          resource :availability, only: %i[show update]
          namespace :availability do
            resource :time_slots, only: %i[show]
          end
          resources :transactions, only: %i[index]
          namespace :payments do
            post :connect_account
            resource :bank_account, only: %i[create destroy]
          end

          get '/rates', to: 'rates#index'

          resources :expert_calls, only: %i[index] do
            get 'details', to: 'expert_calls#show'
            post 'chat_room', to: 'expert_calls#new_chat_room'
            get 'chat_room', to: 'expert_calls#chat_room'
            scope module: 'expert_calls' do
              resource :reschedule, only: %i[create] do
                resource :rescheduling_request do
                  put ':rescheduling_request_id/accept', to: 'reschedules#accept'
                  put ':rescheduling_request_id/decline', to: 'reschedules#decline'
                end
              end
              resource :cancel, only: %i[update]
              resource :request_time_change, only: %i[create]
            end
            patch :finish_calls, on: :member, to: 'expert_calls/finish_calls#update'
            scope module: 'expert_calls' do
              resources :time_additions, only: [], module: 'time_additions' do
                resource :confirm, only: %i[update]
              end
            end
          end
          put 'expert_calls/:id/confirm_schedule',
              to: 'expert_calls/confirm_schedule#update',
              as: :expert_calls_confirm_schedule
          post 'expert_calls/:id/join',
               to: 'expert_calls/join#create',
               as: :expert_calls_join
          get 'calendar_events', to: 'calendars#events', as: 'expert_calendar_events'
          get 'app_policies', to: 'app_policies#index', as: 'expert_policies'
        end

        namespace :individual do
          resource :user, only: %i[update]
          resource :profiles, only: %i[create]
          resources :quick_questions, only: %i[index show create] do
            scope module: 'quick_questions' do
              resource :attachment, only: %i[show]
              put 'feedback', to: 'interactions#update'
            end
          end
          resource :private_chats, only: %i[create] do
            get '/', to: 'private_chats#index'
            get ':private_chat_id', to: 'private_chats#show', on: :member
            put ':private_chat_id/read', to: 'private_chats#read_messages', on: :member
          end
          resource :complaints, only: %i[create]
          resources :expert_calls, only: %i[create index] do
            get 'details', to: 'expert_calls#show'
            post 'chat_room', to: 'expert_calls#new_chat_room'
            get 'chat_room', to: 'expert_calls#chat_room'
            post :join, on: :member, to: 'expert_calls/join#create'
            patch :finish_calls, on: :member, to: 'expert_calls/finish_calls#update'
            scope module: 'expert_calls' do
              resource :time_additions, only: %i[create]
            end

            scope module: 'expert_calls' do
              resource :guest_in_call, only: [], module: 'guest_in_call' do
                resource :confirm, only: %i[update]
              end
              resource :confirm_reschedule, only: %i[update]
              resource :reschedule, only: %i[create] do
                resource :rescheduling_request do
                  put ':rescheduling_request_id/accept', to: 'reschedules#accept'
                  put ':rescheduling_request_id/decline', to: 'reschedules#decline'
                end
              end
              resource :cancel, only: %i[update]
              resource :request_time_change do
                put ':time_change_request_id/accept', to: 'request_time_changes#accept'
                put ':time_change_request_id/decline', to: 'request_time_changes#decline'
              end
              put 'feedback', to: 'interactions#update'
            end
          end
          resources :transactions, only: %i[index]
          namespace :expert_calls do
            resource :individual_search, only: %i[show]
          end
          namespace :payments do
            get :public_key
            get :ephemeral_key
            get :client_secret_key
            resources :credit_cards, only: %i[index]
          end
          resources :experts, only: %i[show] do
            get :search, on: :collection
            get :featured, on: :collection
            get :top, on: :collection
            get :great, on: :collection
            resource :availability, only: %i[show], to: 'experts/availabilities#show'
            get 'reviews', to: 'experts/reviews#index'
          end
          get 'calendar_events', to: 'calendars#events', as: 'individual_calendar_events'
          get 'app_policies', to: 'app_policies#index', as: 'individual_policies'
          get 'app_policies/:id', to: 'app_policies#show', as: 'individual_policy'

        end

        resources :categories, only: %i[index show]
        resources :territories, only: %i[index show]
      end
    end
  end
end
