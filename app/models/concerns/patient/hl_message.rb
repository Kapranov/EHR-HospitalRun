module Patient::HlMessage
  def hl_message
    [message_header_seg, event_type_seg, patient_seg, provider_seg, patint_visit_seg] + vital_segs + lab_segs + allergy_segs + diagnoses_segs + procedure_segs + [guarantor_seg] + insurance_segs
  end

  private

  def message_header_seg
    "MSH|^~\\&|||||#{hl_time}||ADT^A01|MSG00001-|P|2.6"
  end

  def event_type_seg
    "EVN|A01|#{hl_time}"
  end

  def patient_seg
    "PID|#{id}||PATID#{id}||#{first_name}^#{last_name}||#{hl_time(birth)}|#{gender_code}||#{race_code}|#{xad_param(self)}|GL|#{hl_phone(primary_phone)}|#{hl_phone(mobile_phone)}~#{hl_phone(work_phone)}|#{language_code}|||||||#{hl_ethnicity_code}".upcase
  end

  def provider_seg
    "ROL||UC|RT|#{xcn_param(created_by)}|||||||#{xad_param(created_by)}".upcase
  end

  def patint_visit_seg
    "PV1||C"
  end

  def vital_segs
    vital = Patient.first.encounters.try(:last).try(:vital)
    if vital
      ["OBX||NM|BODY HEIGHT||#{vital.height_in_m}|m|||||I".upcase,
       "OBX||NM|BODY WEIGHT||#{vital.weight_in_kg}|kg|||||I".upcase]
    else
      []
    end
  end

  def lab_segs
    lab_orders.map do |lab|
      test_order = lab.test_orders.first
      test_order.present? ? "OBX||ST|#{test_order.code}||#{test_order.result}|#{test_order.units}||#{test_order.flag}|||I" : nil
    end.compact
  end

  def allergy_segs
    allergies.map { |allergy| "AL1|#{allergy.id}||#{allergy.allergen_type}".upcase }
  end

  def diagnoses_segs
    diagnoses.map { |diag| "DG1|#{diag.id}||#{diag.snomed.try(:conceptId)}|#{diag.snomed.try(:defaultTerm)}|#{hl_time(diag.created_at)}|F".upcase }
  end

  def procedure_segs
    procedures.map { |proced| "PR1|#{proced.id}||#{proced.procedure_code.code}||#{hl_time(proced.created_at)}".upcase }
  end

  def guarantor_seg
    "GT1|#{guarantor.id}||#{guarantor.first_name}^#{guarantor.last_name}".upcase
  end

  def insurance_segs
    insurances.map { |ins| "IN1|#{ins.id}|#{ins.insurance_number}|#{ins.claim}".upcase }
  end

  def hl_time(time = Time.now)
    Time.at(time).utc.to_formatted_s(:number)[0..-3] if time
  end

  def hl_phone(phone)
    "(#{phone[2..4]})#{phone[5..7]}-#{phone[8..-1]}" if phone
  end

  def xcn_param(provider)
    "#{provider.id}^#{provider.first_name}^#{provider.last_name}^^^#{provider.title}"
  end

  def xad_param(person)
    "#{person.street_address}^^#{person.city}^#{person.state}^#{person.zip}"
  end
end