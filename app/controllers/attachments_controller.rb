class AttachmentsController < ApplicationController
  before_action :check_role
  before_action :find_amendment
  before_action :find_attachment, only: [:destroy]

  def new
    @attachment = Attachment.new
  end

  def create
    attachment = Attachment.create(attachment_params)
    if attachment.persisted?
      flash[:notice] = creation_notification(attachment)
    else
      flash[:error] = attachment.errors.full_messages.to_sentence
    end
    redirect_to :back
  end

  def destroy
    @attachment.destroy
    render nothing: true
  end

  protected

  def check_role
    authorize Provider, :admin?
  end

  def patient_id
    params[:patient_id] || params[:attachment][:patient_id]
  end

  def amendment_id
    params[:amendment_id] || params[:attachment][:amendment_id]
  end

  def find_amendment
    @amendment = current_user.main_provider.patients.find(patient_id).amendments.find(amendment_id)
  end

  def find_attachment
    @attachment = @amendment.attachments.find(params[:id])
  end

  def attachment_params
    params.require(:attachment).permit(
        :amendment_id,
        :file_name
    )
  end
end