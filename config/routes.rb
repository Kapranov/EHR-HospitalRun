Rails.application.routes.draw do

  root to: 'landings#index'

  %w( 404 422 500 ).each do |code|
    get code, to: 'errors#show', code: code
  end

  resources :admin, only: [:index, :update] do
    collection do
      get :sign_in, to: 'admin_sessions#sign_in'
    end
  end

  namespace :admin do
    resources :users, except: [:show] do
      member do
        get  :delete_confirmation
        get  :activate
        post :activated
        post :suspend
        post :pay
        post :trial
      end
    end
    namespace :settings do
      get   :index
      patch :update
    end
  end

  resources :advanced_directives, only: [:edit, :update]

  resources :alerts, only: [:index, :new, :create, :update] do
    collection do
      get :diagnosis_index
      get :activate_all
      get :activate
    end
  end

  resources :allergies, only: [:create, :update] do
    collection do
      get :form
      get :reconciliation
    end
    member do
      post :previous_reconciliation
      post :confirm_reconciliation
    end
  end

  resources :amendments,   only: [:new, :create, :edit, :update, :destroy]

  resources :appointments, only: [:new, :create, :update, :show, :destroy] do
    collection do
      get :referrals
      get :patients
      get :patient_full_info
      get :reschedule
    end
  end

  resources :attachments,   only: [:new, :create, :destroy]

  resources :audit_logs,    only: [:index] do
    collection do
      get :search
      get :download_csv
    end
  end

  resources :billing, only: [:index] do
    collection do
      get   :switch_tab
      get   :patients
      get   :download_csv
      get   :download_pdf
    end
  end

  resources :block_outs, only: [:create]

  resources :calendars do
    collection do
      get :schedule
      get :open_reschedule
      patch :reschedule
      get :get_calendars
      get :filter
      get :targets
      get :download_csv
    end
    member do
      post :move
      post :resize
    end
  end

  resources :ccdas, only: [:new, :create] do
    collection do
      get :download
      get :preview_xml
      get :preview_html
    end
  end

  resources :debug, only: [:index]

  resources :diagnoses, only: [:index, :create, :update] do
    collection do
      get  :form
      get  :education_materials
      post :add_education_material
      get  :reconciliation
    end
    member do
      post :previous_reconciliation
      post :confirm_reconciliation
    end
  end

  namespace :diagnosis_codes do
    get :diagnosis_codes
  end

  namespace :dosespot do
    get :sync_allergies
    get :sync_medications
  end

  resources :education_attachments, only: [:destroy]
  resources :education_materials, except: [:show]

  resources :email_messages, only: [:index, :new, :create] do
    collection do
      get  :add_subject
      get  :get_subjects
      get  :update_subject
      get  :remove_subject
      post :create_main
      post :create_to_practice
      post :create_from_patient_to_practice
      post :create_reply
      get  :patients
      get  :practices
      get  :patient_practices
      get  :open_message
      get  :new_message_to_patient
      get  :forward_message_from_patient
      get  :new_message_in_practice
      get  :new_message_to_practice
      get  :reply_to_message_in_practice_contacts
      get  :forward_message_in_practice_contacts
      get  :contacts
      get  :contacts_pagination
      get  :contacts_practices
      get  :find_practices
      get  :add_contact
      get  :new_contact
      get  :message
      get  :new_tab
      get  :to_archive
      get  :delete_message
      get  :search_message
      get  :favorite_contact
      get  :mark_as_read
    end
  end

  resources :encounters, only: [:create, :update] do
    collection do
      get :form
      get :encounters
      get :encounter_full_info
    end
  end

  resources :erxes, only: [:edit, :update]

  match 'explorer', to: 'tables#index', via: [:get]

  resources :family_health_histories, only: [:new, :create, :edit, :update] do
    member do
      delete :destroy_dx
    end
  end
  resources :files, only: [:create, :destroy]

  resources :guarantors, only: [:update] do
    collection do
      get :guarantor
    end
  end

  resources :image_orders, except: [:show] do
    member do
      get    :new_attachment
      delete :destroy_test_order
    end
    collection do
      get :search
      get :search_by_order_num
      get :patient_info
    end
  end

  resources :image_results, only: [:update] do
    collection do
      get  :imaging
      get  :form
      post :add_image
      get :search_by_image_order
      get :results_search_by_image_order
    end
  end

  resources :immunizations, except: [:destroy, :show] do
    collection do
      get :name_block
      get :vaccines
      get :download_csv
      get :download_pdf
    end
  end

  resources :insurances, only: [:new, :create]
  resources :lab_orders, except: [:show] do
    member do
      get    :new_attachment
      delete :destroy_test_order
    end
    collection do
      get :search
      get :search_by_order_num
      get :patient_info
    end
  end

  resources :lab_results, except: [:index, :show] do
    collection do
      get :search_by_lab_order
      get :results_search_by_lab_order
      get :test_order_form
    end
  end

  namespace :landings do
    get :index
  end

  namespace :loinc_search do
    get :search
  end

  resources :locations, only: [:create, :update] do
    collection do
      get :form
      get :primary_location
    end
  end

  resources :medications, only: [:index, :create, :update] do
    collection do
      get :form
      get :portions
      get :medications
      get :reconciliation
    end
    member do
      post :previous_reconciliation
      post :confirm_reconciliation
    end
  end

  namespace :medline_plus_search do
    get :search
  end

  resources :past_medical_histories, only: [:edit, :update]

  resources :patient_appointments, only: [:new, :create]

  resources :patient_treatments, only: [:index] do
    collection do
      get :search_patients
      get :active_patients
      get :show_patient
      get :show_patient_chart
      get :show_patient_dental_chart
      get :show_patient_perio_chart
      get :show_patient_profile
      get :show_patient_insurance
      get :show_patient_erx
      get :show_patient_amendments
      get :registrate
    end
  end

  resources :patients, only: [:index, :new, :create, :update] do
    collection do
      post :simple_create
      get  :appointments_show
      get  :appointments_status_actions
      get  :provider_full_info
      get  :myprofile
      patch :update_myprofile
      get  :myhealth
      get  :patients
    end
  end

  resources :payers, only: [:new, :create] do
    collection do
      get :payers
    end
  end

  namespace :payments do
    get    :agreement
    patch  :proceed_payment
    get    :order
    post   :create_subscribtion
    get    :cart
    get    :details
    patch  :update_subscribtion
    get    :card_info
    patch  :update

    get    :shop
    get    :quote
    get    :quote_price
    get    :quote_confirmation

    get    :order_selects_data

    delete :destroy_subscription
  end

  namespace :practice_sessions do
    get :sign_in
  end

  resources :practices,  only: [:new, :create, :edit, :update] do
    collection do
      post  :activate
      post  :admin
      patch :change_password
    end
  end

  resources :procedures, only: [:new, :create, :edit, :update] do
    collection do
      get :procedures
      get :procedure_codes
    end
  end

  resources :providers do
    collection do
      get :schedule
      get :show_myaccount
      get :request_emergency_access
      patch :update_emergency_access
      get :set_emergency_access
      get :invite_to_portal
      get :download_pdf
      get :send_invite_email
      get :add_patient_from_appointment
      post :save_message
      get :destroy_message
      get :prev_message
      get :next_message
      get :first_message
      get :patients
      get :lock
      post :unlock
      get  :providers
      get :invite_to_portal_redirect_patients_index
    end
  end

  resources :referrals,  only: [:new, :create]
  resources :reports,    only: [:index, :new, :create, :edit, :update] do
    collection do
      get :criteria
    end
  end

  resources :representatives do
    collection do
      post :activate
    end
    member do
      post :reset_password
    end
  end

  resources :secure_questions, only: [:index, :update, :message, :edit] do
    collection do
      get   :check
      patch :verify
      get :message
    end
  end

  namespace :settings do
    get   :practice
    get   :access_permissions
    patch :update_permissions
    get   :schedule
    patch :update_schedule
    get   :add_user_added_practice
    get   :set_location_color
    get   :get_schedule_fields
    get   :update_schedule_fields
    get   :update_schedule_color_fields
    get   :add_schedule_fields
    get   :destroy_schedule_fields
  end

  resources :smoking_statuses, only: [:new, :create]

  namespace :snomed do
    get :snomeds
  end

  namespace :sorter do
    get :appointments
    get :messages
    get :todos
  end

  resources :syndromic_surveillances, only: [:index]

  resources :tables, except: [:show] do
    collection do
      get :records
    end
  end

  namespace :tooth_tables do
    get   :tooth_activity
    get   :show_patient_full_perio
    patch :update_full_perio
    get   :show_patient_perio_data_entry
    patch :update_tooth
    get   :set_tooth_bsp
  end

  resources :triggers, only: [:new, :create, :destroy]

  resources :medline_plus do
    collection do
      get :info
    end
  end

  resources :street_addresses do
    collection do
      get :registration_addresses
    end
  end

  resources :area_codes do
    collection do
      get :get_area_codes
    end
  end

  namespace :two_factor_authorization do
    post :enable
    post :disable
  end

  devise_for :users,
             controllers: {
                 confirmations: 'confirmations',
                 passwords:     'passwords',
                 registrations: 'registration',
                 sessions:      'duo_sessions'
             }

  devise_scope :user do
    get  '/users/sign_out' => 'duo_sessions#destroy'
    post '/users/second_step' => 'duo_sessions#second_step'
    get  '/users/registrations/complete' => 'registration#complete'
    get  'active'  => 'duo_sessions#active'
    get  'timeout' => 'duo_sessions#timeout'
  end

  namespace :web_console do
    get :show_web_console_alert
  end

  namespace :zipcode do
    post :city_set
    post :state_set
    post :zip_set
  end

  if Rails.env.development?
    namespace :debug do
      get :select2
    end
  end
end
