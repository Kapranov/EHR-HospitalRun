class EducationAttachmentsController < ApplicationController
  before_action :check_role
  before_action :find_education_material
  before_action :find_attachment

  def destroy
    @education_attachment.destroy
    render nothing: true
  end

  protected

  def check_role
    authorize Provider, :admin?
  end

  def find_education_material
    @education_material = current_user.main_provider.education_materials.find(params[:education_material_id])
  end

  def find_attachment
    @education_attachment = @education_material.find_attachemnt(params[:id])
  end
end