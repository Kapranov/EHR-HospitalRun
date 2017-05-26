class PaymentsController < ApplicationController
  layout 'providers_payments'

  before_action proc{ redirect_to payments_agreement_path unless current_user.provider.subscribed? }, except: [:agreement, :proceed_payment]
  before_action :set_count, only: [:shop, :order, :cart, :card_info, :quote, :quote_price, :details, :details_show]

  def agreement
    @payment_agreement_sign = current_user.provider.payment_agreement_sign
  end

  def proceed_payment
    if current_user.provider.payment_agreement_sign.update(payment_agreement_sign_params)
      redirect_to payments_shop_path
    else
      redirect_to :back
    end
  end

  def order
    @ehr_subscription = EhrSubscription.new
  end

  def order_selects_data
    case params[:type]
    when 'doctors'
      title = 'Doctor'
      price = params[:annual_subscription] == 'true' ? (Payment.plans[:annual])[:amount] : EhrSubscription.rates[:doctor]
    when 'staff'
      title = 'Staff aux. staff member'
      price = EhrSubscription.rates[:staff]
    end

    if title.present? && price.present?
      data = (1..5).map{ |number| {
        id: number.to_s,
        number: number.to_s,
        title: "#{title}#{'s' if number > 1}",
        price: "$#{sprintf("%.2f", price * number)}",
        text: number.to_s
      } }
    else
      data = []
    end
    render json: data
  end


  def create_subscribtion
    current_user.provider.ehr_subscription.destroy if current_user.provider.ehr_subscription.present?
    ehr = EhrSubscription.create(ehr_subscription_create_params)
    if ehr.persisted?
      ehr.payment.update(annual: params[:annual])
      flash[:notice] = creation_notification(ehr)
      redirect_to payments_cart_path
    else
      flash[:error] = ehr.errors.fill_messages.to_sentence
      redirect_to :back
    end
  end

  def cart
    @ehr_subscription = current_user.provider.ehr_subscription
    @payment          = @ehr_subscription.try(:payment)
  end

  def details
    @provider = current_user.provider
    @ehr_subscription = current_user.provider.ehr_subscription
  end

  def update_subscribtion
    ehr = current_user.provider.ehr_subscription
    is_filled = (!ehr.billing_email.nil? || !ehr.technical_email.nil?)
    if ehr.update(ehr_subscription_update_params)
      flash[:notice] = updation_notification(ehr)
      redirect_to payments_card_info_path
    else
      flash[:error] = ehr.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  def destroy_subscription
    @ehr_subscription = current_user.provider.ehr_subscription
    if params[:staff]
      @ehr_subscription.update(staff: nil, additional_staff: false)
    end
    if params[:ehr]
      @ehr_subscription.destroy
    end
    redirect_to payments_cart_path
  end

  def card_info
    @ehr_subscription = current_user.provider.ehr_subscription
    @payment = current_user.provider.ehr_subscription.payment
    @cards   = Payment.cards
    @months = (1..12).map { |month| [month <= 9 ? '0'+month.to_s : month.to_s, month <= 9 ? '0'+month.to_s : month.to_s] }
    @years = (Time.now.year..Time.now.year+8).map { |year| [year.to_s[2..3], year.to_s[2..3]] }
  end

  def update
    payment = current_user.provider.ehr_subscription.payment
    if payment.update(payment_params) && payment.pay
      redirect_to payments_quote_price_path
    else
      flash[:error] = payment.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  def shop
  end

  def quote
    @provider = current_user.provider
    @ehr_subscription = current_user.provider.ehr_subscription
    @payment          = @ehr_subscription.try(:payment)
  end

  def quote_price
    @ehr_subscription = current_user.provider.ehr_subscription
    @payment          = @ehr_subscription.try(:payment)
  end

  def quote_confirmation
  end

  protected

  def set_count
    ehr_subscription = current_user.provider.ehr_subscription
    @count = ehr_subscription.try(:get_count)
  end

  def payment_agreement_sign_params
    params.require(:payment_agreement_sign).permit(:full_name, :agreement)
  end

  def payment_params
    params.require(:payment).permit(
      :annual,
      :card,
      :card_num,
      :cvc,
      :expiration_at,
      :expiration_at_month,
      :expiration_at_year,
      :card_name
    )
  end

  def ehr_subscription_create_params
    params.require(:ehr_subscription).permit(
        :doctors,
        :additional_staff,
        :staff
    ).merge(provider_id: current_user.provider.id)
  end

  def ehr_subscription_update_params
    params.require(:ehr_subscription).permit(
        :billing,
        :billing_first_name,
        :billing_last_name,
        :billing_email,
        :billing_phone,
        :billing_phone_code,
        :billing_phone_tel,
        :technical,
        :technical_first_name,
        :technical_last_name,
        :technical_email,
        :technical_phone,
        :technical_phone_code,
        :technical_phone_tel
    )
  end
end