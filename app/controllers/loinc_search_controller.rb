class LoincSearchController < ApplicationController
  before_action :check_role

  def search
    render json: if params[:part].present?
                   Loinc.find_loinc_by params[:part]
                 else
                   Loinc.limit(10)
                 end.map{ |loinc| { loinc_num: loinc.loinc_num, description: loinc.description } }
  end

  protected

  def check_role
    authorize EducationMaterial, :display?
  end
end