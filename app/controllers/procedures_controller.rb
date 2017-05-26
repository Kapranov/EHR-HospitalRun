class ProceduresController < ApplicationController
  before_action :check_role,     only: [:create, :update]
  before_action :find_patient,   only: [:new, :create, :edit, :update, :procedures]

  def new
    @procedure      = Procedure.new
    @surface        = Surface.new
    @pit            = Pit.new
    @cusp           = Cusp.new
    @procedure_code = ProcedureCode.where(code: params[:code]).first if params[:code].present?
    @tooth          = @patient.tooth_tables.where(tooth_num: params[:tooth_num]).first
  end

  def create
    procedure = Procedure.create(procedure_params)
    if procedure.persisted?
      surface = Surface.create(surface_params.merge(procedure_id: procedure.id))
      pit = Pit.create(pit_params.merge(procedure_id: procedure.id))
      cusp = Cusp.create(cusp_params.merge(procedure_id: procedure.id))
      if surface.persisted? && pit.persisted? && cusp.persisted?
        log 1, 0, @patient.try(:id)
        flash[:notice] = creation_notification(procedure)
        redirect_to show_patient_patient_treatments_path(id: @patient.id)
      else
        flash[:error] = surface.errors.full_messages.to_sentence unless surface.persisted?
        flash[:error] = pit.errors.full_messages.to_sentence     unless pit.persisted?
        flash[:error] = cusp.errors.full_messages.to_sentence    unless cusp.persisted?
        redirect_to new_procedure_path(patient_id: @patient.id)
      end
    else
      flash[:error] = procedure.errors.full_messages.to_sentence
      redirect_to new_procedure_path(patient_id: @patient.id)
    end
  end

  def edit
    @procedure = @patient.procedures.find(params[:id])
  end

  def update
    procedure = @patient.procedures.find(params[:id])
    if procedure.update(procedure_params)
      log 1, 1, @patient.try(:id)
      flash[:notice] = 'Procedure updated successfully'
      redirect_to show_patient_patient_treatments_path(id: @patient.id)
    else
      flash[:error] = procedure.errors.full_messages.to_sentence
      redirect_to edit_procedure_path(procedure, patient_id: @patient.id)
    end
  end

  def procedures
    log 1, 3, @patient.try(:id)
    render json: if params[:part].present?
                   @patient.procedures.where(:procedure_code_id.in =>
                                                 ProcedureCode.where(or: [{code:       /^#{params[:part]}/},
                                                                          {nomenclature: /^#{params[:part]}/}]).map(&:id))
                 else
                   @patient.procedures.limit(10)
                 end.map{ |procedure| {full_name: procedure.procedure_code.try(:to_label) || '', id: procedure.id} }
  end

  def procedure_codes
    log 1, 3
    render json: if params[:part].present?
                   ProcedureCode.where(or: [{code:       /^#{params[:part]}/},
                                            {nomenclature: /^#{params[:part]}/}])
                 else
                   ProcedureCode.limit(10)
                 end.map{ |code| {full_name: code.to_label, id: code.id} }
  end

  protected

  def procedure_params
    params.require(:procedure).permit(
        :patient_id,
        :procedure_code_id,
        :tooth_table_id,
        :date_of_service,
        :status
    )
  end

  def surface_params
    params.require(:procedure).require(:surface).permit(
        :procudure_id,
        :mesial,
        :incisal,
        :distal,
        :lingual,
        :facial,
        :class_five
    )
  end

  def pit_params
    params.require(:procedure).require(:pit).permit(
        :procudure_id,
        :mesial,
        :mesiobuccal,
        :mesiolingual,
        :distal,
        :distobuccal,
        :distolingual
    )
  end

  def cusp_params
    params.require(:procedure).require(:cusp).permit(
        :procudure_id,
        :mesiobuccal,
        :mesiolingual,
        :distobuccal,
        :distolingual
    )
  end

  def find_patient
    @patient = Patient.find(params[:procedure].present? ? params[:procedure][:patient_id] : params[:patient_id])
  end

  def check_role
    authorize Procedure
  end
end