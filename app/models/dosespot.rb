class Dosespot
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  include Dosesp::Referralable

  field :prefix,                      type: String, max_length: 35
  field :first_name,                  type: String, max_length: 35
  field :middle_name,                 type: String, max_length: 35
  field :last_name,                   type: String, max_length: 35
  field :suffix,                      type: String, max_length: 35
  field :birth,                       type: String
  field :gender,                      type: String
  field :social_number,               type: String, max_length: 35
  field :first_address,               type: String, max_length: 35
  field :second_address,              type: String, max_length: 35
  field :city,                        type: String, max_length: 50
  field :state,                       type: String, max_length: 50
  field :zip,                         type: String

  has_many   :dosespot_pharmacies
  belongs_to :patient

  def secrets
    Rails.application.secrets
  end

  def server
    "#{secrets.endpoint}://#{secrets.dose_server}"
  end

  def key
    patient.provider.erx.clinic_key
  end

  def clinic_id
    patient.provider.erx.clinic_id
  end

  def login_url
    "#{server}/#{patient.provider.erx.login_url}"
  end

  def code(phrase)
    phrase + remove_extra_equals_signs(Digest::SHA2.new(512).base64digest(phrase + key))
  end

  def verify(phrase)
    remove_extra_equals_signs(Digest::SHA2.new(512).base64digest(user_id + phrase[0..21] + key))
  end

  def user_id
    patient.try(:provider).try(:dosespot_user_id).to_s
  end

  def valid_url?
    required_fields.each do |field|
      return false if send(field).blank?
    end
    true
  end

  def registrate
    if patient.dosespot_patient_id.blank?
      dosespot_patient_id = Net::HTTP.get_response(URI.parse(url))['location'].split('?')[1].gsub('PatientID=', '')
      patient.update(dosespot_patient_id: dosespot_patient_id)
    end
  end

  def url
    if valid_url?
      phrase = SecureRandom.base64(24)

      url = "#{login_url}?#{ secrets.dose_b_param }=#{ secrets.dose_b }"
      params = [
        [secrets.dose_clinic_id_param,      clinic_id],
        [secrets.dose_user_id_param,        user_id],
        [secrets.dose_phrase_length_param,  secrets.dose_phrase_length],
        [secrets.dose_code_param,           code(phrase).escape_cgi],
        [secrets.dose_user_id_verify_param, verify(phrase).escape_cgi],
        [secrets.dose_prefix_param,         prefix.escape_cgi],
        [secrets.dose_first_name_param,     first_name.escape_cgi],
        [secrets.dose_middle_name_param,    middle_name.escape_cgi],
        [secrets.dose_last_name_param,      last_name.escape_cgi],
        [secrets.dose_suffix_param,         suffix.escape_cgi],
        [secrets.dose_birth_param,          birth],
        [secrets.dose_gender_param,         gender],
        [secrets.dose_first_address_param,  first_address.escape_cgi],
        [secrets.dose_second_address_param, second_address.escape_cgi],
        [secrets.dose_city_param,           city.escape_cgi],
        [secrets.dose_state_param,          state],
        [secrets.dose_zipcode_param,        zip],
        [secrets.dose_primary_phone_param,  first_phone],
        [secrets.dose_primary_phone_type_param, secrets.dose_primary_phone_type],
        [secrets.dose_pharmacy_id_param,    secrets.dose_pharmacy_id]
      ]
      if second_phone.present?
        params << [secrets.dose_first_phone_additional_param, second_phone]
        params << [secrets.dose_first_phone_additional_type_param, secrets.dose_first_phone_additional_type]
      end
      params.each {|param, value| url << "&#{param}=#{value}"}
      url.html_safe
    end
  end

  def patient_detail_url
    phrase = SecureRandom.base64(24)

    if patient.dosespot_patient_id.present?
      url = "#{server}/#{secrets.dose_secure_url}?PatientID=#{patient.dosespot_patient_id}"
      [
          [secrets.dose_b_param, secrets.dose_b],
          [secrets.dose_clinic_id_param, clinic_id],
          [secrets.dose_user_id_param, user_id],
          [secrets.dose_phrase_length_param, secrets.dose_phrase_length],
          [secrets.dose_code_param, code(phrase).escape_cgi],
          [secrets.dose_user_id_verify_param, verify(phrase).escape_cgi]
      ].each {|param, value| url << "&#{param}=#{value}"}
      url
    end
  end

  def required_fields
    [:first_name, :last_name, :birth, :gender, :first_address, :city, :state, :zip, :first_phone]
  end

  def full_message
    required_fields.map { |field| "#{field} is required" if send(field).blank? }
                   .reject{ |message| message.blank? }.to_sentence.gsub('_', ' ')
  end

  def first_phone
    phone = patient.primary_phone.present? ? patient.primary_phone
                                           : (patient.mobile_phone.present? ? patient.mobile_phone : patient.work_phone)
    phone[2..-1] if phone.present?
  end

  def second_phone
    if patient.primary_phone.present?
      phone = patient.mobile_phone.present? ? patient.mobile_phone : patient.work_phone
      phone[2..-1] if phone.present?
    end
  end

  def remove_extra_equals_signs(digest)
    digest[-1] == digest[-2] ? digest[0..-3] : digest
  end
end
