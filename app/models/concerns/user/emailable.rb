module User::Emailable
  def inbox
    EmailMessage.where(to_id: user_id_for_email_messages,  draft: false, archive: false)
  end

  def sent
    EmailMessage.where(from_id: user_id_for_email_messages, draft: false, archive: false)
  end

  def draft
    EmailMessage.where(from_id: user_id_for_email_messages, draft: true, archive: false)
  end

  def urgent
    EmailMessage.where(to_id: user_id_for_email_messages, draft: false, urgent: true, archive: false)
  end

  def archive
    EmailMessage.where(to_id: user_id_for_email_messages, draft: false, archive: true)
  end
end