require 'csv'

class BillingController < ApplicationController
  layout 'providers_billing'

  before_action :find_patient, only: [:download_csv, :download_pdf]

  def index
    @patients = current_user.provider.main_provider.patients
    @patient = current_user.provider.main_provider.patients.first
  end

  def switch_tab
    render partial: 'billing/tab_container', locals: { patient: current_user.provider.main_provider.patients.find(params[:patient_id]) }
  end

  def download_pdf
    file_name = 'Billing.pdf'
    pdf = BillingPdf.new(@patient.procedures)
    send_data pdf.render,
              filename: file_name,
              type: 'application/pdf'
  end

  def download_csv
    file_name = 'Billing.csv'
    File.delete(file_name) if File.exist?(file_name)
    CSV.open(file_name, 'wb') do |csv|
      csv << ['Date of Service',
              'Code',
              'Description',
              'Tooth',
              'Surface']
      @patient.procedures.each do |procedure|
        csv << [procedure.date_of_service.try(:strftime, Date::DATE_FORMATS[:dosespot]),
                procedure.procedure_code.try(:code),
                procedure.encounter.try(:notes),
                procedure.tooth_table.try(:tooth_num),
                procedure.surface.try(:get_all_true_fields)]
      end
    end
    send_file(
        "#{Rails.root}/#{file_name}",
        filename: file_name
    )
  end

  def patients
    render json: current_user.provider.main_provider.patients.where(or: [{first_name: /^#{params[:part]}/}, {last_name: /^#{params[:part]}/}])
                                                   .map { |patient| { id: patient.id, full_name: patient.full_name } }
  end

  protected

  def find_patient
    @patient = current_user.provider.main_provider.patients.find(params[:patient_id])
  end
end
