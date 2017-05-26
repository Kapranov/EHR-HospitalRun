class TriggersController < ApplicationController
  before_action proc { authorize :cds, :configure? }

  def new
    @trigger = Trigger.new
    @alert_id = params[:alert_id]
    @trigger_categories = current_user.provider.trigger_categories_collection
    @systems = Trigger.systems
  end

  def create
    if current_user.main_provider.alerts.map(&:id).include? params[:trigger][:alert_id]
      @trigger = Trigger.create(trigger_params)
      if @trigger.persisted?
        flash[:notice_more] = creation_notification_more(@trigger)
        redirect_to alerts_path
      else
        flash[:errors] = @trigger.errors.full_messsages.to_sentence
        redirect_to new_trigger_path
      end
    else
      flash[:errors] = 'Invalid alert'
      redirect_to new_trigger_path
    end
  end

  def destroy
    trigger = Trigger.where(:alert_id.in => Provider.first.alerts.map(&:id), id: params[:id]).first
    trigger.destroy if trigger.present?
    redirect_to :back
  end

  def info
  end

  protected

  def trigger_params
    params.require(:trigger).permit(
        :trigger_category_id,
        :alert_id,
        :system,
        :code,
        :description
    )
  end
end