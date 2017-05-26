require 'concerns/modellogger.rb'
require 'csv'

class ImmunizationsController < ApplicationController
  include ModelLogger

  before_action :find_patient

  def index
    authorize Immunization, :show?
    @immunizations = @patient.immunizations
  end

  def new
    authorize Immunization, :create?
    @immunization = Immunization.new
  end

  def create
    authorize Immunization
    immunization = Immunization.create(immunization_params)
    create_log(immunization)
    if immunization.persisted?
      log 1, 0, params[:immunization][:patient_id]
      flash[:notice] = creation_notification(immunization)
      redirect_to show_patient_patient_treatments_path(id: params[:immunization][:patient_id])
    else
      flash[:error] = immunization.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  def edit
    authorize Immunization, :update?
    @immunization = @patient.immunizations.find(params[:id])
    @logs = read_log(@immunization)
  end

  def update
    authorize Immunization
    immunization = @patient.immunizations.find(params[:id])
    update_log(immunization)
    if immunization.update(immunization_params)
      log 1, 1, params[:immunization][:patient_id]
      flash[:notice] = updation_notification(immunization)
      redirect_to show_patient_patient_treatments_path(id: params[:immunization][:patient_id])
    else
      flash[:error] = immunization.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  def name_block
    authorize Immunization, :show?
    if params[:type_general] && params[:type].present?
      @immunization = params[:id].present? ? @patient.immunizations.find(params[:id]) : Immunization.new
      render partial: 'form', locals: { type_general: params[:type_general], type: params[:type] }, layout: nil
    end
  end

  def vaccines
    authorize Immunization, :show?
    log 1, 3
    render json: if params[:part].present?
                   Vaccine.where(name: /^#{params[:part]}/)
                 else
                  Vaccine.limit(10)
                 end.map{ |vaccine| { name: vaccine.name, id: vaccine.id } }
  end

  def download_pdf
    authorize Immunization, :show?
    file_name = 'Immunization.pdf'
    pdf = ImmunizationPdf.new(@patient.immunizations)
    log 1, 4, @patient.try(:id)
    send_data pdf.render,
              filename: file_name,
              type: 'application/pdf'
  end

  def download_csv
    authorize Immunization, :show?
    file_name = 'Immunization.csv'
    File.delete(file_name) if File.exist?(file_name)
    CSV.open(file_name, 'wb') do |csv|
      csv << ['Vaccine',
              'Type',
              'Admin. Date',
              'Administered by']
      @patient.immunizations.each do |immunization|
        csv << [immunization.vaccine.try(:name),
                immunization.name,
                immunization.administered_at.try(:strftime, Date::DATE_FORMATS[:dosespot]),
                immunization.administered_by.try(:to_label)]
      end
    end
    log 1, 4, @patient.try(:id)
    send_file(
        "#{Rails.root}/#{file_name}",
        filename: file_name
    )
  end

  private

  def find_patient
    @patient = current_user.provider.main_provider.patients.find(params[:immunization][:patient_id])
  end

  def immunization_params
    params.require(:immunization).permit(
        :patient_id,
        :vaccine_id,
        :name,
        :administered_at_date,
        :administered_at_time,
        :refused_at,
        :refused_at_date,
        :refused_at_time,
        :source_of_information,
        :reason_refused,
        :manufacturer,
        :lot,
        :quantity,
        :dose,
        :unit,
        :expiration_at,
        :expiration_at_date,
        :expiration_at_time,
        :route,
        :body_site,
        :funding_source,
        :registry_notification,
        :vfc_class,
        :comments,
        :administered_by_id,
        :ordered_by_id,
        :administered_facility_id,
        :facility_id,
    )
  end
end