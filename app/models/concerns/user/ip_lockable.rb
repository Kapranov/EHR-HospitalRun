module User::IpLockable
  def first_enter?
    role == :Patient && !patient.secure_question.set?
  end

  def locked_ip?(ip)
    role == :Patient &&
    last_sign_in_ip != nil &&
    last_sign_in_ip != ip
  end

  def update_ip(ip)
    update(ip_locked: locked_ip?(ip), current_sign_in_ip: ip, last_sign_in_ip: ip) if ip.present?
  end

  def unlock_ip
    update(ip_locked: false)
  end
end