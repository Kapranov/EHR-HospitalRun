class FilesController < ApplicationController
  before_action :check_role, :set_klass_container
  before_action :find_attachment, only: [:destroy]

  def create
    attachment = Attachment.create(attachment_params)
    if attachment.persisted?
      @container.add_attachment(attachment)
      flash[:notice] = creation_notification(attachment)
    else
      flash[:error] = attachment.errors.full_messages.to_sentence
    end
    redirect_to params[:back_path].present? ? params[:back_path] : :back
  end

  def destroy
    @container.remove_attachment(@attachment)
    @attachment.destroy
    render nothing: true
  end

  protected

  def check_role
    authorize Provider, :admin?
  end

  def set_klass_container
    @klass     = params[:model].to_s.constantize
    @container = @klass.find(params["#{params[:model].snakecase}_id"]) if @klass.present?
    redirect_to :back if @container.blank? || !@klass.ancestors.include?(AttachmentCollectionable)
  end

  def find_attachment
    @attachment = Attachment.find(params[:id])
  end

  def attachment_params
    params.require(:attachment).permit(
      :file_name
    )
  end
end