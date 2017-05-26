class LabOrdersController < ApplicationController
  layout 'providers_labs'

  # before_action :check_role
  before_action :set_search_collection,               only: [:index,  :search]
  before_action :find_lab_order,                      only: [:edit,   :update,  :destroy, :destroy_test_order, :new_attachment]
  before_action :find_test_orders, :find_attachments, only: [:edit]
  before_action :set_collections,                     only: [:new,    :edit]

  def index
    @lab_orders = current_user.provider.lab_orders
  end
  
  def new
    @lab_order  = LabOrder.new
    @test_order = TestOrder.new
    @lab_results = current_user.provider.results_without_order_collection
  end

  def create
    @lab_order = LabOrder.create(lab_order_params)
    if @lab_order.persisted?
      after_successful_create
      flash[:notice] = creation_notification(@lab_order)
      redirect_to lab_orders_path
    else
      flash[:error] = @lab_order.errors.full_messages.to_sentence
      redirect_to lab_orders_path
    end
  end

  def edit
    @lab_results = current_user.provider.results_without_order_collection if @lab_order.lab_result.blank?
  end

  def update
    if @lab_order.update(lab_order_params)
      after_successful_update
      flash[:notice] = updation_notification(@lab_order)
      redirect_to lab_orders_path
    else
      flash[:error] = @lab_order.errors.full_messages.to_sentence
      redirect_to edit_lab_order_path(@lab_order)
    end
  end

  def destroy
    @lab_order.destroy
    log 5, 2, @lab_order.patient.try(:id)
    flash[:notice] = deletion_notification(@lab_order)
    redirect_to lab_orders_path
  end

  def destroy_test_order
    test_order = @lab_order.test_orders.find(params[:test_order_id])
    test_order.destroy if test_order.present?
    render nothing: true
  end

  def new_attachment
    @attachment = Attachment.new
  end

  def search
    @lab_orders = current_user.provider.lab_orders.where(and: [{provider_id: params[:provider_id]},
                                                   {order_type:  params[:order_type]},
                                                   {status:      params[:status]}]).to_a
    .find_all { |lab_order| lab_order.test_orders.where(or: [{test: /^#{params[:part]}/},
                                                 {code: /^#{params[:part]}/}]).to_a.any? }
    log 5, 3
    render partial: 'lab_orders'
  end

  def search_by_order_num
    order_num = params[:order_num].to_i
    if order_num.present? and order_num.is_a? Integer
      render json: current_user.provider.lab_orders.where(order_num: order_num).to_a
    else
      render nothing: true
    end
  end

  def patient_info
    render json: if params[:part]
                   current_user.main_provider.patients.where(or: [{first_name: /^#{params[:part].downcase.titleize}/}, {last_name: /^#{params[:part].downcase.titleize}/}])
                 else
                   current_user.main_provider.patients_first(10)
                 end.map { |patient| { id: patient.id, sex: patient.gender, age: patient.age, dob: patient.birth_date, primary_phone: patient.primary_phone, full_name: patient.full_name } }
  end

  protected

  def set_search_collection
    @providers     = current_user.provider.providers_collection.map { |provider| 
      provider[0] = 'Dr. '+provider[0],
      provider[1] = provider[1]
    }.to_a
    @order_types   = LabOrder.order_types
    @statuses      = LabOrder.statuses
  end

  # def check_role
  #   authorize Provider, :admin?
  # end

  def find_lab_order
    @lab_order = current_user.provider.lab_orders.find(params[:id])
  end

  def find_test_orders
    @test_orders = @lab_order.test_orders
    @test_order  = TestOrder.new
  end

  def find_attachments
    @attachments = @lab_order.all_attachments
  end

  def set_collections
    @order_types         = LabOrder.order_types
    @lab_order_names     = LabOrder.names
    @statuses            = LabOrder.statuses
    @ordering_physicians = [[current_user.provider.full_name, current_user.provider.id]]
    @ordering_facilities = LabOrder.ordering_facilities
    @lab_order_statuses  = LabOrder.lab_statuses
  end

  def lab_order_params
    params.require(:lab_order).permit(
        :patient_id,
        :order_type,
        :lab_name,
        :status,
        :ordering_physician,
        :ordering_facility,
        :lab_status,
        :schedule_at,
        :schedule_at_date,
        :received_at,
        :received_at_date,
        :notes
    ).merge(provider_id: current_user.provider.id)
  end

  def create_test_orders(lab_order)
    params[:lab_order][:test_orders][:new].each do |_, p|
      TestOrder.create(test_order_params(p).merge(lab_order_id: lab_order.id))
    end if params[:lab_order][:test_orders].present? && params[:lab_order][:test_orders][:new].present? && params[:lab_order][:test_orders][:new].any?
  end

  def edit_test_orders(lab_order)
    params[:lab_order][:test_orders][:edit].each do |_, p|
      test_order = lab_order.test_orders.find(p[:id])
      test_order.update(test_order_params(p)) if test_order.present?
    end if params[:lab_order][:test_orders].present? &&  params[:lab_order][:test_orders][:edit].present? && params[:lab_order][:test_orders][:edit].any?
  end

  def test_order_params(p)
    p.permit(:code, :test)
  end

  def create_attachments
    attachments = params[:lab_order][:attachments]
    if attachments.present? && attachments.any?
      attachments.each do |_, value|
        @lab_order.add_attachment(Attachment.create(file_name: value))
      end
    end
  end

  def after_successful_create
    create_test_orders(@lab_order)
    create_attachments
    LabResult.find(params[:lab_result_id]).update(lab_order_id: @lab_order.id) if params[:lab_result_id].present?
    log 5, 0, @lab_order.patient.try(:id)
  end

  def after_successful_update
    create_test_orders(@lab_order)
    edit_test_orders(@lab_order)
    create_attachments
    LabResult.find(params[:lab_result_id]).update(lab_order_id: @lab_order.id) if params[:lab_result_id].present?
    log 5, 1, @lab_order.patient.try(:id)
  end
end
