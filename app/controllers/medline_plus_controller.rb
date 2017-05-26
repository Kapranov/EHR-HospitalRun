class MedlinePlusController < ApplicationController

  def info
    secrets = Rails.application.secrets

    if params[:link].present?
      @title = params[:title]
      @link = params[:link]
    else
      @title = "#{ params[:snomed_concept_id] } (SNOMED) - #{ params[:snomed_term] }"
      @link = "https://#{ secrets.medline_plus_server }/#{ secrets.medline_plus_api_url }?#{ secrets.medline_plus_code_system_param }=#{ secrets.medline_plus_code_system }"
      @link << "&#{ secrets.medline_plus_code_param }=#{ params[:snomed_concept_id] }"
      @link << "&#{ secrets.medline_plus_description_param }=#{ params[:snomed_term] }"
      @link << "&output=embed"

      @link = URI.escape(@link);
    end
  end

end