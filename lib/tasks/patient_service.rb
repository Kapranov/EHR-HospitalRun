class PatientService

  def self.create
    current_provider = Provider.first

    user = FactoryGirl.create :user,
      email:          Rails.application.secrets.ehr_patient_email,
      password:       Rails.application.secrets.ehr_patient_password,
      password_confirmation: Rails.application.secrets.ehr_patient_password,
      role:           :Patient
    user.confirm

    patient = FactoryGirl.create :patient, user_id: user.id, provider_id: current_provider.id, created_by_id: current_provider.id

    referral = FactoryGirl.create :referral

    FactoryGirl.create(
        :appointment,
        patient_id:         patient.id,
        referral_id:        referral.id,
        location_id:        current_provider.location.id,
        room:               current_provider.rooms.first,
        appointment_type:   current_provider.appointment_types.first,
        appointment_status: current_provider.appointment_statuses.first)

    FactoryGirl.create :block_out,  patient_id: patient.id
    allergy1 = FactoryGirl.create :allergy, patient_id: patient.id
               FactoryGirl.create :allergy, patient_id: patient.id, referral: true, note: allergy1.note

    allergy2 = FactoryGirl.create :allergy, patient_id: patient.id
               FactoryGirl.create :allergy, patient_id: patient.id, referral: true, note: allergy2.note

    allergy3 = FactoryGirl.create :allergy, patient_id: patient.id
               FactoryGirl.create :allergy, patient_id: patient.id, referral: true, note: allergy3.note

    diagnosis1 = FactoryGirl.create :diagnosis, patient_id: patient.id
                 FactoryGirl.create :diagnosis, patient_id: patient.id, referral: true, snomed_id: diagnosis1.snomed_id, acute: false, terminal: false

    diagnosis2 = FactoryGirl.create :diagnosis, patient_id: patient.id
                 FactoryGirl.create :diagnosis, patient_id: patient.id, referral: true, snomed_id: diagnosis2.snomed_id, acute: false, terminal: false

    diagnosis3 = FactoryGirl.create :diagnosis, patient_id: patient.id
                 FactoryGirl.create :diagnosis, patient_id: patient.id, referral: true, snomed_id: diagnosis3.snomed_id, acute: false, terminal: false

    medication1 = FactoryGirl.create :medication, diagnosis_id: diagnosis1.id
                  FactoryGirl.create :medication, diagnosis_id: diagnosis1.id, referral: true, shorthand: medication1.shorthand

    medication2 = FactoryGirl.create :medication, diagnosis_id: diagnosis2.id
                  FactoryGirl.create :medication, diagnosis_id: diagnosis2.id, referral: true, shorthand: medication2.shorthand

    medication3 = FactoryGirl.create :medication, diagnosis_id: diagnosis1.id
                  FactoryGirl.create :medication, diagnosis_id: diagnosis1.id, referral: true, shorthand: medication3.shorthand

    payer = FactoryGirl.create :payer, patient_id: patient.id
    FactoryGirl.create :claim, payer_id: payer.id

    FactoryGirl.create :next_kin,           patient_id: patient.id
    FactoryGirl.create :guarantor,          patient_id: patient.id
    FactoryGirl.create :emergency_contact,  patient_id: patient.id

    FactoryGirl.create :smoking_status,        patient_id: patient.id
    FactoryGirl.create :past_medical_history,  patient_id: patient.id
    FactoryGirl.create :advanced_directive,    patient_id: patient.id
    FactoryGirl.create :immunization,          patient_id: patient.id

    payer     = FactoryGirl.create :payer,     patient_id: patient.id
    insurance = FactoryGirl.create :insurance, patient_id: patient.id, payer_id: payer.id

    FactoryGirl.create :claim,      payer_id:   payer.id
    FactoryGirl.create :subscriber, insurance_id: insurance.id
    FactoryGirl.create :employer,   insurance_id: insurance.id

    procedure_code = FactoryGirl.create :procedure_code
    encounter = FactoryGirl.create :encounter, patient_id: patient.id
    procedure = FactoryGirl.create :procedure, patient_id: patient.id,
                                        procedure_code_id: procedure_code.id,
                                        encounter_id: encounter.id,
                                        tooth_table_id: patient.tooth_tables.first.id

    FactoryGirl.create :surface, procedure_id: procedure.id

    FactoryGirl.create :vital,                  encounter_id: encounter.id
    FactoryGirl.create :procedure_completed,    encounter_id: encounter.id
    FactoryGirl.create :procedure_recommended,  encounter_id: encounter.id

    FactoryGirl.create :patient_appointment, patient_id: patient.id

    create_test_messages(current_provider.user, user)
  end

  def self.create_test_messages(provider, patient)
    FactoryGirl.create :email_message,  to_id: provider.id, from_id: patient.id
    FactoryGirl.create :urgent,         to_id: patient.id,  from_id: provider.id
    FactoryGirl.create :archive,        to_id: patient.id,  from_id: provider.id
  end
end
