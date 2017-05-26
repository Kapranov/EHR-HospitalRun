require 'csv'

class CalendarsController < ApplicationController
  before_action :check_role,    except: [:open_reschedule, :reschedule, :move]
  before_action :load_calendar, only:   [:edit, :update, :destroy, :move, :resize]

  layout 'providers'

  def show
    redirect_to appointment_path(Calendar.find(params[:id]).appointment)
  end

  def open_reschedule
    authorize Appointment, :reschedule?
    @calendar = Calendar.find(params[:id])
    @start_time = @calendar.start_time + params[:days].to_i.days
    @days = params[:days]
  end

  def reschedule
    authorize Appointment, :reschedule?
    appointment = Calendar.find(params[:id]).appointment
    new_datetime = appointment.appointment_datetime + params[:days].to_i.days
    appointment.appointment_datetime_date = new_datetime.to_date.to_s(:frontend_date)
    appointment.appointment_datetime_time = "#{'%02d' % new_datetime.to_time.hour}:#{'%02d' % new_datetime.to_time.min}"
    appointment.appointment_datetime = new_datetime
    appointment.save
    if params[:reschedule]
      body = "Your appointment rescheduled from #{params[:old_show_start_time]} to #{params[:new_show_start_time]}"
      TextMessage.create(patient_id: appointment.patient_id, provider_id: current_user.provider.id, to: appointment.patient.user.email, from: current_user.email, body: body)
      EmailMessage.create(to: appointment.patient.user, from: current_user, body: body, draft: false)
    end
    redirect_to :back
  end

  def schedule
    @providers  = current_user.provider.all_providers
    @calendars = prepare_calendars(current_user.provider.appointments.map(&:calendar))
    @settings  = prepare_settings
    prepare_filter_params
  end

  def get_calendars
    @calendars = Calendar.where(and: [{:start_time.ge => Time.at(params['start'].to_i).to_formatted_s(:db)},
                                      {:end_time.le   => Time.at(params['end'].to_i).to_formatted_s(:db)}])
    render json: prepare_calendars(@calendars).to_json
  end

  def move
    authorize Appointment, :reschedule?
    if @calendar
      @calendar.start_time = make_time_from_minute_and_day_delta(@calendar.start_time)
      @calendar.end_time   = make_time_from_minute_and_day_delta(@calendar.end_time)
      @calendar.all_day   = params[:all_day]
      @calendar.save
    end
    render nothing: true
  end

  def resize
    if @calendar
      @calendar.end_time = make_time_from_minute_and_day_delta(@calendar.end_time)
      @calendar.save
    end
    render nothing: true
  end

  def edit
    render json: { form: render_to_string(partial: 'edit_form') }
  end

  def destroy
    case params[:delete_all]
      when 'true'
        @calendar.calendar_serial.destroy
      when 'future'
        @calendars = @calendar.calendar_serial.calendars.where(:start_time.gt => @calendar.start_time.to_formatted_s(:db)).reject{ |c| c.id == @calendar.id }.to_a
        @calendar.calendar_serial.calendars.delete(@calendars)
      else
        @calendar.destroy
    end
    render nothing: true
  end

  def download_csv
    file_name = 'Schedule.csv'
    datetime = params[:current_date].to_time
    appointments = current_user.provider.appointments.where(:appointment_datetime.eq => (datetime.beginning_of_month..datetime.end_of_month))
    File.delete(file_name) if File.exist?(file_name)
    CSV.open(file_name, 'wb') do |csv|
      csv << ['Date',
              'Provider',
              'Reason']
      appointments.each do |appointment|
        csv << [appointment.appointment_datetime.try(:strftime, Date::DATE_FORMATS[:dosespot]),
                appointment.provider.full_name,
                appointment.reason]
      end
    end
    send_file(
        "#{Rails.root}/#{file_name}",
        filename: file_name
    )
  end

  def filter
    appointments = current_user.provider.appointments.where(conditions)
    if appointments.any?
      render json: prepare_calendars(appointments.map(&:calendar))
    else
      render plain: ''
    end
  end

  def targets
    if option = set_target
      render partial: "calendars/#{option}_filter_li", locals: { provider: Provider.find(params[:id]) }
    else
      render nothing: true
    end
  end

  private

  def prepare_calendars(calendars)
    calendars.map do |calendar|
      {
          id: calendar.id,
          start: calendar.start_time.iso8601,
          end: calendar.end_time.iso8601,
          allDay: calendar.all_day,
          recurring: (calendar.calendar_serial_id) ? true : false,
          typeColor: calendar.appointment.appointment_type.try(:colour),
          statusColor: calendar.appointment.appointment_status.try(:colour),
          patientName: calendar.appointment.patient.full_name,
          patientPhone: calendar.appointment.patient.mobile_phone,
          providerName: calendar.appointment.patient.provider.full_name,
          type: calendar.appointment.appointment_type.try(:appt_type),
          status: calendar.appointment.appointment_status.try(:name),
          room: calendar.appointment.room.try(:room),
          roomId: calendar.appointment.room_id
      }
    end
  end

  def prepare_settings
    general = current_user.provider.schedule_general
    {
        minTime: general.calendar_from.strftime('%H:%M:%S'),
        maxTime: general.calendar_to.strftime('%H:%M:%S'),
        snapDuration: general.snap_duration
    }
  end

  def prepare_filter_params
    @provider_ids = [current_user.provider.id].to_json.html_safe
    @location_ids = current_user.provider.locations.map(&:id).to_json.html_safe
    @room_ids     = current_user.provider.rooms.map(&:id).to_json.html_safe
    @appointment_status_ids = current_user.provider.appointment_statuses.map(&:id).to_json.html_safe
    @appointment_type_ids = current_user.provider.appointment_types.map(&:id).to_json.html_safe
  end

  def conditions
    conds = []
    %w(provider_id location_id room_id appointment_status_id appointment_type_id).each do |field|
      conds << { field.to_sym.in => params[field.pluralize.to_sym] } if params[field.pluralize.to_sym].present?
    end
    conds.any? ? { and: conds } : { provider_id: '' }
  end

  def load_calendar
    @calendar = Calendar.find(params[:id])
    unless @calendar
      render json: { message: "Calendar Not Found.."}, status: 404 and return
    end
  end

  def calendar_params
    params.require(:calendar).permit(
        :title,
        :description,
        :start_time,
        :end_time,
        :all_day
    )
  end

  def make_time_from_minute_and_day_delta(calendar_time)
    params[:minute_delta].to_i.minutes.from_now((params[:day_delta].to_i).days.from_now(calendar_time))
  end

  def set_target
    %(location room appointment_status appointment_type).include?(params[:target]) ? params[:target] : nil
  end

  def check_role
    authorize :calendar, :show?
  end
end
