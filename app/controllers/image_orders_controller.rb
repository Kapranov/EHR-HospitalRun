class ImageOrdersController < ApplicationController
  layout 'providers_imaging'

  # before_action :check_role
  before_action :set_search_collection,   only: [:index,  :search]
  before_action :find_image_order,        only: [:edit,   :update,  :destroy, :destroy_test_order, :new_attachment]
  before_action :find_test_orders, :find_attachments, only: [:edit]
  before_action :set_collections,         only: [:new,    :edit]

  def index
    @image_orders = current_user.provider.image_orders
  end

  def new
    @image_order  = ImageOrder.new
    @test_order = TestOrder.new
  end

  def create
    @image_order = ImageOrder.create(image_order_params)
    if @image_order.persisted?
      after_successful_create
      flash[:notice] = creation_notification(@image_order)
      redirect_to image_orders_path
    else
      flash[:error] = @image_order.errors.full_messages.to_sentence
      redirect_to new_image_order_path
    end
  end

  def edit
  end

  def update
    if @image_order.update(image_order_params)
      after_successful_update
      flash[:notice] = updation_notification(@image_order)
      redirect_to image_orders_path
    else
      flash[:error] = @image_order.errors.full_messages.to_sentence
      redirect_to edit_image_order_path(@image_order)
    end
  end

  def destroy
    @image_order.destroy
    log 5, 2, @image_order.patient.try(:id)
    flash[:notice] = deletion_notification(@image_order)
    redirect_to image_orders_path
  end

  def destroy_test_order
    test_order = @image_order.test_orders.find(params[:test_order_id])
    test_order.destroy if test_order.present?
    render nothing: true
  end

  def new_attachment
    @attachment = Attachment.new
  end

  def search
    @image_orders = current_user.provider.image_orders.where(and: [{provider_id: params[:provider_id]},
                                                                   {order_type:  params[:order_type]},
                                                                   {status:      params[:status]}]).to_a
    .find_all { |image_order| image_order.test_orders.where(or:   [{test: /^#{params[:part]}/},
                                                                   {code: /^#{params[:part]}/}]).to_a.any? }
    log 5, 3
    render partial: 'image_orders'
  end

  def patient_info
    render json: if params[:part]
                   current_user.main_provider.patients.where(or: [{first_name: /^#{params[:part].downcase.titleize}/}, {last_name: /^#{params[:part].downcase.titleize}/}])
                 else
                   current_user.main_provider.patients_first(10)
                 end.map { |patient| { id: patient.id, sex: patient.gender, age: patient.age, dob: patient.birth_date, primary_phone: patient.primary_phone, full_name: patient.full_name } }
  end

  def search_by_order_num
    order_num = params[:order_num].to_i
    if order_num.present? and order_num.is_a? Integer
      render json: current_user.provider.image_orders.where(order_num: order_num).to_a
    else
      render nothing: true
    end
  end

  protected

  def set_search_collection
    @providers     = current_user.provider.providers_collection.map { |provider|
      provider[0] = 'Dr. '+provider[0],
          provider[1] = provider[1]
    }.to_a
    @order_types   = ImageOrder.order_types
    @statuses      = ImageOrder.statuses
  end

  # def check_role
  #   authorize Provider, :admin?
  # end

  def find_image_order
    @image_order = current_user.provider.image_orders.find(params[:id])
  end

  def find_test_orders
    @test_orders = @image_order.test_orders
    @test_order  = TestOrder.new
  end

  def find_attachments
    @attachments = @image_order.all_attachments
  end

  def set_collections
    @order_types         = ImageOrder.order_types
    @image_order_names   = ImageOrder.names
    @statuses            = ImageOrder.statuses
    @ordering_physicians = [[current_user.provider.full_name, current_user.provider.id]]
    @ordering_facilities = ImageOrder.ordering_facilities
    @image_order_statuses = ImageOrder.image_statuses
  end

  def image_order_params
    params.require(:image_order).permit(
        :patient_id,
        :order_type,
        :image_name,
        :status,
        :ordering_physician,
        :ordering_facility,
        :image_status,
        :schedule_at,
        :schedule_at_date,
        :received_at,
        :received_at_date,
        :notes
    ).merge(provider_id: current_user.provider.id)
  end

  def create_test_orders(image_order)
    params[:image_order][:test_orders][:new].each do |_, p|
      TestOrder.create(test_order_params(p).merge(image_order_id: image_order.id))
    end if params[:image_order][:test_orders].present? && params[:image_order][:test_orders][:new].present? && params[:image_order][:test_orders][:new].any?
  end

  def edit_test_orders(image_order)
    params[:image_order][:test_orders][:edit].each do |_, p|
      test_order = image_order.test_orders.find(p[:id])
      test_order.update(test_order_params(p)) if test_order.present?
    end if params[:image_order][:test_orders].present? &&  params[:image_order][:test_orders][:edit].present? && params[:image_order][:test_orders][:edit].any?
  end

  def test_order_params(p)
    p.permit(:code, :test)
  end

  def create_attachments
    attachments = params[:image_order][:attachments]
    if attachments.present? && attachments.any?
      attachments.each do |_, value|
        @image_order.add_attachment(Attachment.create(file_name: value))
      end
    end
  end

  def after_successful_create
    create_test_orders(@image_order)
    create_attachments
    log 5, 0, @image_order.patient.try(:id)
  end

  def after_successful_update
    create_test_orders(@image_order)
    edit_test_orders(@image_order)
    create_attachments
    log 5, 1, @image_order.patient.try(:id)
  end
end
