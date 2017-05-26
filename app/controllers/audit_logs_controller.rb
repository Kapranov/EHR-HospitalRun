require 'csv'

class AuditLogsController < ApplicationController
  layout 'providers_settings'

  def index
    @audit_logs = AuditLog.where(:provider_id.in => current_user.main_provider.all_providers.map(&:id)).paginate(page: params[:page], per_page: 10)
  end

  def search
    @audit_logs = AuditLog.where(filter_params).paginate(page: params[:page], per_page: 10)
    render partial: 'audit_logs/audit_logs'
  end

  def download_csv
    file_name = 'Audit.csv'
    File.delete(file_name) if File.exist?(file_name)
    @audit_logs = AuditLog.where(:provider_id.in => current_user.main_provider.all_providers.map(&:id))
    CSV.open(file_name, 'wb') do |csv|
      csv << ['Date', 'Time', 'Patient', 'User', 'Data type', 'Action', 'Details']
      @audit_logs.each do |log|
        csv << [log.created_at_date,
                log.created_at_time,
                log.patient.try(:full_name),
                log.provider.try(:full_name),
                log.action,
                log.data_type,
                log.detail]
      end
    end
    send_file("#{Rails.root}/#{file_name}", filename: file_name)
  end

  private

  def filter_params
    filter_param = []
    filter_param << {:created_at.gt => params[:created_at_from].to_date.to_s(:db).to_time.beginning_of_day} if params[:created_at_from].present?
    filter_param << {:created_at.lt => params[:created_at_to].to_date.to_s(:db).to_time.end_of_day}         if params[:created_at_to].present?
    filter_param << {provider_id: params[:provider_id]} if params[:provider_id].present?
    if params[:patient_part].present?
      filter_param << {:patient_id.in => current_user.main_provider.find_patients_by(params[:patient_part]).map(&:id)}
    end
    filter_param.count > 1 ? {and: filter_param} : filter_param
  end
end