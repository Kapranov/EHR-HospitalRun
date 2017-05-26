class ProviderService
  def self.create
    user = FactoryGirl.create :user,
      email:          Rails.application.secrets.ehr_provider_email,
      password:       Rails.application.secrets.ehr_provider_password,
      password_confirmation: Rails.application.secrets.ehr_provider_password
    user.confirm

    provider = FactoryGirl.create :provider, user_id: user.id

    3.times do |i|
      FactoryGirl.create :room, provider_id: provider.id, room: "OR#{i + 1}"
    end
    AppointmentStatus.examples.each do |status|
      FactoryGirl.create :appointment_status, provider_id: provider.id, name: status
    end
    AppointmentType.examples.each do |type|
      FactoryGirl.create :appointment_type, provider_id: provider.id, appt_type: type
    end

    5.times { |i| create_location(provider, i) }
    provider.update(location_id: Location.first.id)
  end

  def self.create_location(provider, i)
    location = FactoryGirl.create :location,
      provider_id:      provider.id,
      location_npi:     "FRE32#{i}1",
      location_tin_en:  "DSE#{i}3423"

    Timeslot.weekdays.each do |weekday|
      FactoryGirl.create :timeslot,
        location_id:  location.id,
        weekday:      weekday
    end
  end

  def self.create_practice(provider)
    FactoryGirl.create :practice,
      provider_id:  provider.id,
      location_id:  provider.locations.first.id
  end
end
