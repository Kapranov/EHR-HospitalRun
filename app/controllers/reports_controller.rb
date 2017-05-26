require 'csv'

class ReportsController < ApplicationController
  layout 'providers_reports'

  before_action :set_criterias,  only: [:criteria, :new, :edit]

  def index
    @reports = Report.all.paginate(page: params[:page], per_page: 10)
  end

  def criteria
  end

  def new
    if params[:criteria].present?
      @report = Report.new(criteria: params[:criteria], query: [])
      render partial: @report.partial_name('filters')
    else
      flash[:error] = 'Nothing is chosen'
      render nothing: true
    end
  end

  def create
    @report = Report.create(report_params)
    if params[:import].present?
      create_csv
    else
      redirect_to edit_report_path(@report)
    end
  end

  def edit
    @report   = Report.find(params[:id])
    @patients = Patient.find_by_report(@report)
  end

  def update
    @report = Report.find(params[:id])
    @report.update(report_params)
    if params[:import].present?
      create_csv
    else
      redirect_to edit_report_path(@report)
    end
  end

  private

  def report_params
    params.require(:report).permit(
        :criteria,
        :created_at_date,
        :created_at_time
    ).merge(query: params[:report][:query], category: :Patients, list: :'Patient Lists')
  end

  def set_criterias
    @criterias = Patient.reportable_criteria_names
  end

  def create_csv
    file_name = 'Report.csv'
    File.delete(file_name) if File.exist?(file_name)
    CSV.open(file_name, 'wb') do |csv|
      csv << ['First', 'Last', 'Pt ID', 'DOB', 'Age', 'Sex', 'Preferred Contact', 'Status', 'Added']
      Patient.find_by_report(@report).each do |patient|
        csv << [patient.first_name, patient.last_name, patient.id, patient.birth.try(:strftime, Date::DATE_FORMATS[:dosespot]),
                patient.age, patient.gender, patient.preferred_contact_value, patient.active, patient.created_at.strftime(Date::DATE_FORMATS[:dosespot])]
      end
    end
    send_file("#{Rails.root}/#{file_name}", filename: file_name)
  end
end
