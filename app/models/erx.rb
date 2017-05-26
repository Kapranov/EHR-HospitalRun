class Erx
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :clinic_id,      type: Integer,    default: Rails.application.secrets.dose_clinic_id
  field :clinic_key,     type: String,     default: Rails.application.secrets.dose_clinic_key
  field :api_url,        type: String,     default: Rails.application.secrets.dose_api_url
  field :login_url,      type: String,     default: Rails.application.secrets.dose_url

  belongs_to :provider
end