module AttachmentCollectionable
  def self.included(base)
    base.class_eval do
      field :attachments, type: Array, default: []

      before_destroy :destroy_attachments
    end
  end

  def attachments?
    attachments.present? && attachments.any?
  end

  def all_attachments
    attachments? ? Attachment.where(:id.in => attachments) : []
  end

  def find_attachemnt(id)
    attachments? && attachments.include?(id) ? Attachment.where(id: id).try(:first) : nil
  end

  def add_attachment(attachment)
    update(attachments: self.attachments << attachment.id)
  end

  def remove_attachment(attachment)
    update(attachments: self.attachments - [attachment.id])
  end

  private

  def destroy_attachments
    all_attachments.destroy_all if attachments?
  end
end