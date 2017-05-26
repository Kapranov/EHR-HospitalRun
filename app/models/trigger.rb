class Trigger
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  def self.systems
    [:Snomed, :Local]
  end

  field :system,           type: Enum,       in: self.systems,       default: self.systems.first
  field :code,             type: String
  field :description,      type: String

  belongs_to :alert
  belongs_to :trigger_category

  def medline_url
    secrets = Rails.application.secrets

    url = "https://#{ secrets.medline_plus_server }/#{ secrets.medline_plus_api_url }?#{ secrets.medline_plus_code_system_param }=#{ secrets.medline_plus_code_system }"
    url << "&#{ secrets.medline_plus_code_param }=#{ code }"
    url << "&#{ secrets.medline_plus_description_param }=#{ description }"
    return url;
  end
end
