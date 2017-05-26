class SnomedController < ApplicationController
  before_action :check_role_provider, only: [:snomeds]

  def snomeds
    log 1, 3
    part = params[:part]
    render json: if part.present?
                   Snomed.find_by(part)
                 else
                   Snomed.limit(10)
                 end.map{ |snomed| { id: snomed.id, defaultTerm: snomed.try(:defaultTerm), concept_id: snomed.try(:conceptId), term: snomed.try(:defaultTerm), active: snomed.try(:active) } }
  end

  protected

  def check_role_provider
    authorize Provider, :provider?
  end
end
