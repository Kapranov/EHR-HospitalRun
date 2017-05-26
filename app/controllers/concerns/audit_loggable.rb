module AuditLoggable
  def log(data_type_num, action_num, patient_id = nil, details = default_details)
    AuditLog.create(data_type:   data_type(data_type_num),
                    action:      action(action_num),
                    patient_id:  patient_id,
                    provider_id: current_user.provider.try(:id),
                    detail:      details)
  end

  protected

  def default_details
    self.class.name.gsub('sController', '').snakecase.humanize
  end

  def data_type(num)
    AuditLog.data_types[num]
  end

  def action(num)
    AuditLog.actions[num]
  end
end