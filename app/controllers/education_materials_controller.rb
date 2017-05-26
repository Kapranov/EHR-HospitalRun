class EducationMaterialsController < ApplicationController
  layout 'providers_settings'

  before_action proc { authorize EducationMaterial, :display? },   only:   [:index]
  before_action proc { authorize EducationMaterial, :configure? }, except: [:index]
  before_action :find_education_material,    only: [:edit, :update, :destroy]
  before_action :prepare_select_collections, only: [:new, :edit]

  def index
    @education_materials = current_user.main_provider.education_materials
  end

  def new
    @education_material = EducationMaterial.new
  end

  def create
    @education_material = EducationMaterial.create(education_material_params.merge(provider_id: current_user.main_provider.id))
    if @education_material.persisted?
      create_attachments
      flash[:notice] = creation_notification(@education_material)
      redirect_to education_materials_path
    else
      flash[:error] = @education_material.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  def edit
    @education_attachments = @education_material.all_attachments
  end

  def update
    if @education_material.update(education_material_params)
      create_attachments
      flash[:notice] = updation_notification(@education_material)
      redirect_to education_materials_path
    else
      flash[:error] = @education_material.errors.full_messages.to_sentence
      redirect_to edit_education_material_path(@education_material)
    end
  end

  def destroy
    @education_material.destroy
    render nothing: true
  end

  protected

  def find_education_material
    @education_material = EducationMaterial.find(params[:education_materials].present? ? params[:education_materials][:id] : params[:id])
  end

  def prepare_select_collections
    @code_systems = EducationMaterial.code_systems
  end

  def education_material_params
    params.require(:education_material).permit(
        :name,
        :code_system,
        :code_id,
        :note
    )
  end

  def create_attachments
    attachments = params[:education_material][:attachments]
    if attachments.present? && attachments.any?
      attachments.each do |_, value|
        @education_material.add_attachment(Attachment.create(file_name: value))
      end
    end
  end
end