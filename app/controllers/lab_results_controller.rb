class LabResultsController < ApplicationController
  layout 'providers_labs'
  
  # before_action :check_role
  before_action :find_lab_result, only: [:edit, :update, :destroy]

  def new
    @lab_order  = current_user.provider.lab_orders.find(params[:order_id]) if params[:order_id].present?
    @lab_result = LabResult.new
    @lab_orders = current_user.provider.lab_orders_collection
  end

  def create
    lab_result = LabResult.create(lab_result_params)
    if lab_result.persisted?
      edit_test_orders(lab_result.lab_order) if lab_result.lab_order.present?
      log 5, 0, lab_result.patient.try(:id)
      flash[:notice] = creation_notification(lab_result)
      redirect_to lab_orders_path
    else
      flash[:error] = lab_result.errors.full_messages.to_sentence
      redirect_to new_lab_result_path
    end
  end

  def edit
    @lab_orders = @lab_result.patient.lab_orders_collection if @lab_result.persisted? && @lab_result.lab_order.blank?
  end

  def update
    if @lab_result.update(lab_result_params)
      edit_test_orders(@lab_result.lab_order) if @lab_result.lab_order.present?
      log 5, 1, @lab_result.patient.try(:id)
      flash[:notice] = updation_notification(@lab_result)
      redirect_to lab_orders_path
    else
      flash[:error] = @lab_result.errors.full_messages.to_sentence
      redirect_to edit_lab_result_path(@lab_result)
    end
  end

  def destroy
    @lab_result.destroy
    log 5, 2, @lab_result.patient.try(:id)
    flash[:notice] = deletion_notification(@lab_result)
    redirect_to lab_orders_path
  end

  def search_by_lab_order
  end

  def results_search_by_lab_order
    @lab_order = current_user.provider.lab_orders.find(params[:id])
  end

  def test_order_form
    lab_order = current_user.provider.lab_orders.find(params[:lab_order_id])
    render partial: 'lab_results/test_order_form', locals: { lab_order: lab_order }
  end

  protected

  # def check_role
  #   authorize Provider, :admin?
  # end

  def find_lab_result
    @lab_result = current_user.provider.lab_results.find(params[:id])
    @lab_order  = @lab_result.lab_order
  end

  def lab_result_params
    params.require(:lab_result).permit(
        :patient_id,
        :lab_order_id,
        :fasting,
        :specimen,
        :specimen_type,
        :test_resported_at,
        :ordering_physician,
        :npi,
        :order_name,
        :order_address,
        :collected_at,
        :received_at,
        :performing_name,
        :performing_address,
        :tested_at,
        :notes
    ).merge(provider_id: current_user.provider.id)
  end

  def edit_test_orders(lab_order)
    if params[:lab_result][:test_orders].present? && params[:lab_result][:test_orders][:edit].present? && params[:lab_result][:test_orders][:edit].any?
      params[:lab_result][:test_orders][:edit].each do |id, p|
        test_order = lab_order.test_orders.find(id)
        test_order.update(test_order_params(p)) if test_order.present?
      end
    end
  end

  def test_order_params(p)
    p.permit(:result, :units, :flag, :range)
  end
end
