class ToothTablesController < ApplicationController
  before_action :check_role, :find_patient

  def tooth_activity
    @patient.tooth_tables.find(params[:id]).update(active: params[:active])
    after_successful_update
    render nothing: true
  end

  def show_patient_full_perio
    tooth = @patient.tooth_tables.find(params[:id])
    if tooth.active
      render partial: 'form_patient_full_perio', locals: { tooth: tooth }
    else
      render nothing: true
    end
  end

  def update_full_perio
    flash[:error] = nil
    tooth = @patient.tooth_tables.find(params[:tooth_table][:id])
    flash[:error] = tooth.errors.full_messages.to_sentence unless tooth.update(fm_f: params[:tooth_table][:fm_f], fm_m: params[:tooth_table][:fm_m])
    params[:tooth_table].each do |field_name, _|
      if %w(pd gm cal mgl).include? field_name
        tooth_field = tooth.send(field_name)
        flash[:error] = tooth_field.errors.full_messages.to_sentence unless tooth_field.update(full_tooth_params(field_name))
      end
    end
    if flash[:error].present?
      redirect_to tooth_tables_show_patient_full_perio_path(id: tooth.id, patient_id: @patient.id)
    else
      after_successful_update
      flash[:notice] = updation_notification(tooth)
      redirect_to show_patient_patient_treatments_path(id: tooth.patient_id)
    end
  end

  def show_patient_perio_data_entry
    field = params[:field]
    if %w(pd gm cal mgl).include? field
      top_teeth    = @patient.tooth_tables.where(:tooth_num.lt => 17).order_by(:tooth_num)
      bottom_teeth = @patient.tooth_tables.where(:tooth_num.gt => 16).order_by(:tooth_num).reverse
      render partial: 'form_patient_perio_data_entry', locals: { patient: @patient, field: field, top_teeth: top_teeth, bottom_teeth: bottom_teeth }
    else
      render nothing: true
    end
  end

  def update_tooth
    flash[:error] = nil
    params[:patient][:tooth_tables].each do |index, tooth|
      if tooth[:tooth_field].present?
        tooth_field = @patient.tooth_tables.find(tooth[:id]).tooth_fields.find(tooth[:tooth_field_id])
        flash[:error] = tooth_field.errors.full_messages.to_sentence unless tooth_field.update(tooth_params(index))
      end
    end
    if flash[:error].present?
      redirect_to tooth_tables_show_patient_perio_data_entry_path(patient_id: @patient.id, field: params[:field])
    else
      after_successful_update
      flash[:notice] = updation_notification(@patient.tooth_tables.first)
      redirect_to show_patient_patient_treatments_path(id: params[:patient][:id])
    end
  end

  def set_tooth_bsp
    tooth = @patient.tooth_tables.find(params[:id])
    tooth.update(params[:field_name] => !tooth.send(params[:field_name]))
    after_successful_update
    render nothing: true
  end

  protected

  def tooth_params(index)
    params.require(:patient).require(:tooth_tables).require(index.to_sym).require(:tooth_field).permit(
        :b1,
        :b2,
        :b3,
        :b_bsp1,
        :b_bsp2,
        :b_bsp3,
        :b_bsp4,
        :b_bsp5,
        :b_bsp6,
        :b_bsp7,
        :b_bsp8,
        :b_bsp9,
        :l1,
        :l2,
        :l3,
        :l_bsp1,
        :l_bsp2,
        :l_bsp3,
        :l_bsp4,
        :l_bsp5,
        :l_bsp6,
        :l_bsp7,
        :l_bsp8,
        :l_bsp9
    )
  end

  def full_tooth_params(tooth_field_name)
    params.require(:tooth_table).require(tooth_field_name.to_sym).permit(
        :b1,
        :b2,
        :b3,
        :b_bsp1,
        :b_bsp2,
        :b_bsp3,
        :b_bsp4,
        :b_bsp5,
        :b_bsp6,
        :b_bsp7,
        :b_bsp8,
        :b_bsp9,
        :l1,
        :l2,
        :l3,
        :l_bsp1,
        :l_bsp2,
        :l_bsp3,
        :l_bsp4,
        :l_bsp5,
        :l_bsp6,
        :l_bsp7,
        :l_bsp8,
        :l_bsp9
    )
  end

  def find_patient
    patient_id = params[:tooth_table].present? ? params[:tooth_table][:patient_id] : params[:patient_id]
    patient_id.present? ? patient_id : params[:patient][:id]
    @patient = Patient.find(patient_id.present? ? patient_id : params[:patient][:id])
  end

  def check_role
    authorize :chart, :perio_update?
  end

  def cache_clear
    Rails.cache.clear "perio_#{@patient.id}"
  end

  def after_successful_update
    log 1, 1, @patient.try(:id), 'Perio chart'
    cache_clear
  end
end