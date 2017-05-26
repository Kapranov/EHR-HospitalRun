class AlertsController < ApplicationController
  layout 'providers_settings'

  before_action proc { authorize :cds, :display? },   only:   [:index]
  before_action proc { authorize :cds, :configure? }, except: [:index]

  def index
    @alerts = current_user.main_provider.alerts
    @alerts_all_state = all_state
    @rules  = Alert.rules
  end

  def diagnosis_index
    @alerts = current_user.main_provider.alerts.where(:id.in => Trigger.where(code: /^#{params[:concept_id]}/).map(&:alert_id))
  end

  def new
    @alert = Alert.new
    @rules = Alert.rules
  end

  def create
    @alert = Alert.create(alert_params.merge(provider_id: current_user.main_provider.id))
    if @alert.persisted?
      flash[:notice_more] = creation_notification_more(@alert)
      redirect_to alerts_path
    else
      flash[:error] = @alert.errors.full_messages.to_sentence
      redirect_to new_alert_path
    end
  end

  def update
    alert = Alert.find(params[:alert][:id])
    alert.update(alert_params) if alert
    redirect_to :back
  end

  def activate_all
    current_user.main_provider.alerts.update_all(active: params[:active] == 'true')
    render nothing: true
  end

  def activate
    current_user.main_provider.alerts.find(params[:id]).update(active: params[:active])
    render nothing: true
  end

  def all_state
    active = false
    @alerts.all? do |alert|
      active = true if alert.active
    end
    return active
  end

  protected

  def alert_params
    params.require(:alert).permit(
        :provider_id,
        :name,
        :description,
        :resolution,
        :bibliography,
        :developer,
        :funding_source,
        :release_date,
        :release_date_date,
        :release_date_time,
        :rule
    )
  end
end