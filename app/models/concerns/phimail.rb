class Phimail
  def self.send(email_message)
    secrets = Rails.application.secrets
    PhiMailConnector.set_server_certificate("#{Rails.root.to_s}/#{secrets.phimail_cert_path}")
    phimail_connector = PhiMailConnector.new(secrets.phimail_server, secrets.phimail_port)
    phimail_connector.authenticate_user(secrets.phimail_user, secrets.phimail_password)

    begin
      # phimail_connector.add_recipient(email_message.to.email) # on real email
      phimail_connector.add_recipient(secrets.phimail_user)     # send to themselves

      phimail_connector.set_subject(email_message.subject.try(:name))
      phimail_connector.add_text(email_message.body)

      phimail_connector.send

      begin
        phimail_connector.close
      rescue
        # ignore
      end

      true
    rescue => e
      email_message.errors.add(:base, e.message)

      begin
        phimail_connector.close
      rescue
        # ignore
      end

      false
    end
  end

  def self.recieve
    secrets = Rails.application.secrets
    PhiMailConnector.set_server_certificate("#{Rails.root.to_s}/#{secrets.phimail_cert_path}")
    phimail_connector = PhiMailConnector.new(secrets.phimail_server, secrets.phimail_port)
    phimail_connector.authenticate_user(secrets.phimail_user, secrets.phimail_password)

    while true
      letter = phimail_connector.check

      break if letter.nil?
      if letter.is_mail?
        from_user = User.where(email: letter.recipient).try(:first)
        to_user   = User.where(email: letter.sender).try(:first)

        if from_user.present? && to_user.present?
          message = EmailMessage.new
          message.to   = from_user
          message.from = to_user

          show_res = phimail_connector.show(0)

          message.subject_id = subject(show_res)
          message.body = body(show_res)
          message.save
        end

        phimail_connector.acknowledge_message
      end
    end
  end

  private

  def self.subject(show_res)
    subj_name = show_res.try(:headers).try(:last)
    if subj_name.present?
      subj_name = subj_name[31..-1]
      subj = Subject.where(name: subj_name).try(:first)
      subj.present? ? subj.id : Subject.create(name: subj_name).id
    else
      nil
    end
  end

  def self.body(show_res)
    show_res.try(:data) if show_res.try(:mime_type).try(:start_with? , 'text/')
  end

end
