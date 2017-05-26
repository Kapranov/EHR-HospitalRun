class LocationsController < ApplicationController
  before_action :check_role

  def form
    @location = params[:id].present? ? Location.find(params[:id]) : Location.new
  end

  def create
    flash[:error] = nil
    location = Location.create(location_params.merge({provider_id: current_user.provider.main_provider.id}))
    params[:location][:timeslots].each do |_, timeslot_params|
      if timeslot_params[:from].present? && timeslot_params[:to].present?
        timeslot_params.parse_time_select! :from
        timeslot_params.parse_time_select! :to
        timeslot = Timeslot.create(timeslot_params(timeslot_params).merge({ location_id: location.id }))
        flash[:error] = timeslot.errors.full_messages.to_sentence if timeslot.errors.present?
      end
    end
    if location.errors.present? || flash[:error].present?
      flash[:error] = "#{location.errors.full_messages.to_sentence} #{flash[:error]}"
      redirect_to form_locations_path
    else
      current_user.provider.update(location_id: location.id)
      flash[:notice] = creation_notification(location)
      remote_redirect_to settings_practice_path
    end
  end

  def update
    location = Location.find(params[:id])
    flash[:error] = nil
    if params[:location][:timeslots].present?
      params[:location][:timeslots].each do |_, p|
        if p[:from].present? && p[:to].present?
          p.parse_time_select! :from
          p.parse_time_select! :to
          timeslot = Timeslot.find(p[:id])
          flash[:error] = timeslot.errors.full_messages.to_sentence unless timeslot.update(timeslot_params(p))
        end
      end
    end
    if !location.update(location_params) || flash[:error].present?
      flash[:error] = "#{location.errors.full_messages.to_sentence} #{flash[:error]}"
      redirect_to form_locations_path(id: location.id)
    else
      flash[:notice] = updation_notification(location)
      remote_redirect_to settings_schedule_path
    end
  end

  def primary_location
    provider = params[:provider_id].present? ? Provider.find(params[:provider_id]) : current_user.provider
    if params[:checked] == 'true'
      provider.update(location_id: params[:id])
    else
      provider.update(location_id: nil)
    end
    render nothing: true
  end

  private

  def location_params
    params.require(:location).permit(
      :provider_id,
      :location_name,
      :location_phone,
      :location_fax,
      :location_phone_code,
      :location_phone_tel,
      :location_fax_code,
      :location_fax_tel,
      :location_address,
      :city,
      :state,
      :zip,
      :location_npi,
      :location_tin_en
    )
  end

  def timeslot_params(parameters)
    parameters.permit(
        :location_id,
        :weekday,
        :from,
        :to,
        :specific_hour
    )
  end

  def check_role
    authorize :setting, :show?
  end
end