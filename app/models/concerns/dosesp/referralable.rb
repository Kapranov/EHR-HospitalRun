require 'net/http'
require 'net/https'

module Dosesp::Referralable

  def request_path
    "/#{secrets.dose_api_url}"
  end

  def xmlns
    'http://www.dosespot.com/API/11/'
  end

  def headers(list)
    {
        'SOAPAction'   => "#{xmlns}#{list}",
        'Content-Type' => 'text/xml; charset=utf-8',
        'Host' => secrets.dose_server
    }
  end

  def http
    net_http = Net::HTTP.new(secrets.dose_server, 80)
    net_http.use_ssl = false
    net_http
  end

  def sync_allergies(provider_id)
    phrase = SecureRandom.base64(24)

    data = <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <AllergyListRequest xmlns="#{xmlns}">
      <SingleSignOn>
        <SingleSignOnClinicId>#{secrets.dose_clinic_id}</SingleSignOnClinicId>
        <SingleSignOnCode>#{code(phrase)}</SingleSignOnCode>
        <SingleSignOnUserId>#{user_id}</SingleSignOnUserId>
        <SingleSignOnUserIdVerify>#{verify(phrase)}</SingleSignOnUserIdVerify>
        <SingleSignOnPhraseLength>#{secrets.dose_phrase_length}</SingleSignOnPhraseLength>
      </SingleSignOn>
      <PatientId>#{patient.dosespot_patient_id}</PatientId>
    </AllergyListRequest>
  </soap:Body>
</soap:Envelope>
    EOF

    resp = http.post(request_path, data, headers('AllergyList'))
    allergies = Nokogiri::XML(resp.body)
    dosespot_allergy_ids = []
    allergies.xpath('//xmlns:AllergyListResult//xmlns:Allergy', 'xmlns' => xmlns).each do |allergy|
      dosespot_allergy_ids << modify_allergy(allergy, provider_id)
    end
    destroy_allergies(dosespot_allergy_ids, provider_id)
  end

  def modify_allergy(allergy, provider_id)
    dosespot_allergy_id = allergy.xpath('xmlns:PatientAllergyId', 'xmlns' => xmlns).text
    if dosespot_allergy_id.present?
      aller          = patient.allergies.where(dosespot_allergy_id: dosespot_allergy_id).try(:first)
      severity_level = allergy.xpath('xmlns:ReactionType', 'xmlns' => xmlns).text == 'AdverseReaction' ? :Severe : :Mild
      active         = allergy.xpath('xmlns:StatusType',   'xmlns' => xmlns).text == 'Active'
      start_at       = allergy.xpath('xmlns:OnsetDate',    'xmlns' => xmlns).text.to_time
      note           = allergy.xpath('xmlns:Name',         'xmlns' => xmlns).text
      if aller.present?
        AuditLog.create(data_type: :Dosespot, action: :Change, patient_id: patient.id, provider_id: provider_id, detail: 'Allergy')
        aller.severity_level  = severity_level
        aller.active          = active
        aller.start_date_date = start_at.to_date.to_s(:frontend_date)
        aller.start_date_time = "#{'%02d' % start_at.to_time.hour}:#{'%02d' % start_at.to_time.min}"
        aller.note            = note
        aller.save
      else
        AuditLog.create(data_type: :Dosespot, action: :Add, patient_id: patient.id, provider_id: provider_id, detail: 'Allergy')
        Allergy.create(
            patient_id:          patient.id,
            dosespot_allergy_id: dosespot_allergy_id,
            allergen_type:      :Drug,
            onset_at:           :Unkhown,
            severity_level:      severity_level,
            active:              active,
            start_date:          start_at,
            note:                note,
            referral:            true
        )
      end
    end
    dosespot_allergy_id
  end

  def destroy_allergies(dosespot_allergy_ids, provider_id)
    if Allergy.where(:id.in => patient.allergies.where(referral: true).reject{ |allergy| dosespot_allergy_ids.include?(allergy.dosespot_allergy_id) }.map(&:id)).destroy_all.any?
      AuditLog.create(data_type: :Dosespot, action: :Delete, patient_id: patient.id, provider_id: provider_id, detail: 'Allergy')
    end
  end

  def sync_medications(provider_id)
    phrase = SecureRandom.base64(24)

    data = <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetMedicationListRequest xmlns="#{xmlns}">
      <SingleSignOn>
        <SingleSignOnClinicId>#{secrets.dose_clinic_id}</SingleSignOnClinicId>
        <SingleSignOnCode>#{code(phrase)}</SingleSignOnCode>
        <SingleSignOnUserId>#{user_id}</SingleSignOnUserId>
        <SingleSignOnUserIdVerify>#{verify(phrase)}</SingleSignOnUserIdVerify>
        <SingleSignOnPhraseLength>#{secrets.dose_phrase_length}</SingleSignOnPhraseLength>
      </SingleSignOn>
      <PatientId>#{patient.dosespot_patient_id}</PatientId>
      <Sources>
        <MedicationSourceType>SelfReported</MedicationSourceType>
      </Sources>
      <Status>
        <MedicationStatusType>Active</MedicationStatusType>
      </Status>
    </GetMedicationListRequest>
  </soap:Body>
</soap:Envelope>
    EOF

    resp = http.post(request_path, data, headers('GetMedicationList'))
    medications = Nokogiri::XML(resp.body)
    dosespot_medication_ids = []
    medications.xpath('//xmlns:Medications//xmlns:MedicationListItem', 'xmlns' => xmlns).each do |medication|
      dosespot_medication_ids << modify_medication(medication, provider_id)
    end
    destroy_medications(dosespot_medication_ids, provider_id)
  end

  def modify_medication(medication, provider_id)
    dosespot_medication_id = medication.xpath('xmlns:MedicationId', 'xmlns' => xmlns).text
    if dosespot_medication_id.present?
      med = Medication.where(and: [{dosespot_medication_id: dosespot_medication_id}, {:diagnosis_id.in => patient.diagnoses.map(&:id)}]).try(:first)
      source     = medication.xpath('xmlns:Source',      'xmlns' => xmlns).text
      shorthand  = medication.xpath('xmlns:DisplayName', 'xmlns' => xmlns).text
      signature  = medication.xpath('xmlns:NDC',         'xmlns' => xmlns).text
      start_date = medication.xpath('xmlns:DateWritten', 'xmlns' => xmlns).text.to_time
      note       = medication.xpath('xmlns:Name',        'xmlns' => xmlns).text
      if med.present?
        AuditLog.create(data_type: :Dosespot, action: :Change, patient_id: patient.id, provider_id: provider_id, detail: 'Medication')
        med.start_date_date = start_date.to_date.to_s(:frontend_date)
        med.start_date_time = "#{'%02d' % start_date.to_time.hour}:#{'%02d' % start_date.to_time.min}"
        med.shorthand       = shorthand
        med.signature       = signature
        med.note            = note
        med.source          = source
        med.save
      else
        diagnosis = Diagnosis.create(patient_id: patient.id, referral: true)
        AuditLog.create(data_type: :Dosespot, action: :Add, patient_id: patient.id, provider_id: provider_id, detail: 'Medication')
        Medication.create(
            dosespot_medication_id: dosespot_medication_id,
            diagnosis_id:           diagnosis.id,
            shorthand:              shorthand,
            signature:              signature,
            start_date:             start_date,
            note:                   note,
            source:                 source,
            referral:               true
        )
      end
    end
    dosespot_medication_id
  end

  def destroy_medications(dosespot_medication_ids, provider_id)
    medication_ids = Medication.where(and: [{referral: true}, {:diagnosis_id.in => patient.diagnoses.map(&:id)}])
                               .reject{ |medication| dosespot_medication_ids.include?(medication.dosespot_medication_id) }.map(&:id)
    if Medication.where(:id.in => medication_ids).destroy_all.any?
      AuditLog.create(data_type: :Dosespot, action: :Delete, patient_id: patient.id, provider_id: provider_id, detail: 'Medication')
    end
  end
end
# %w(Unknown SurescriptsHistory Prescription SelfReported Imported)
# <MedicationSourceType>Unknown</MedicationSourceType>
# <MedicationSourceType>SurescriptsHistory</MedicationSourceType>
# <MedicationSourceType>Prescription</MedicationSourceType>
# <MedicationSourceType>SelfReported</MedicationSourceType>
# <MedicationSourceType>Imported</MedicationSourceType>
# %w(Unknown Active Inactive Completed Discontinued)
# <MedicationStatusType>Unknown</MedicationStatusType>
# <MedicationStatusType>Active</MedicationStatusType>
# <MedicationStatusType>Inactive</MedicationStatusType>
# <MedicationStatusType>Completed</MedicationStatusType>
# <MedicationStatusType>Discontinued</MedicationStatusType>
#  %w(Unknown SurescriptsHistory Prescription SelfReported Imported).each {|so| %w(Unknown Active Inactive Completed Discontinued).each {|st| Patient.last.dosespot.sync_medications(so, st)}}

# <?xml version="1.0" encoding="utf-8"?>
# <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
#   <soap:Body>
#     <AllergyListResult xmlns="http://www.dosespot.com/API/11/">
#       <SingleSignOn>
#         <SingleSignOnClinicId>570</SingleSignOnClinicId>
#         <SingleSignOnCode>e0DUBXCZVNeGrQZ7SjT1KZvnK5c74dY9EMuyB3kamHsQmWW4BoV6yHBeJBgSpDbYTK4kO1yc3ITfa+MTPKLiBNnTNvLIEDFNKbq1YWzgBt5s63i6EcCucA</SingleSignOnCode>
#         <SingleSignOnUserId>1052</SingleSignOnUserId>
#         <SingleSignOnUserIdVerify>5GLoHml6QQotyPv55U7i3OlnjOmbqhsGd6L59MLpVvcE91uU/YOFjFD5vmdJfzGradVHipksqMq6IeE+FYXKzg</SingleSignOnUserIdVerify>
#         <SingleSignOnPhraseLength>32</SingleSignOnPhraseLength>
#       </SingleSignOn>
#       <Result>
#         <ResultCode>OK</ResultCode>
#       </Result>
#       <Allergies>
#         <Allergy>
#           <PatientAllergyId>14699</PatientAllergyId>
#           <Name>Allopurinol Derivatives</Name>
#           <Code>410</Code>
#           <RxCUI xsi:nil="true"/>
#           <CodeType>AllergyClass</CodeType>
#           <Reaction>Bluet vesde kroviu</Reaction>
#           <ReactionType>AdverseReaction</ReactionType>
#           <StatusType>Active</StatusType>
#           <OnsetDate>2016-08-08T00:00:00</OnsetDate>
#         </Allergy>
#       </Allergies>
#     </AllergyListResult>
#   </soap:Body>
# </soap:Envelope>

# <Medications>
#   <MedicationListItem>
#     <MedicationId>22273</MedicationId>
#     <Source>SelfReported</Source>
#     <MedicationStatus>Active</MedicationStatus>
#     <PrescriptionStatus xsi:nil="true"/>
#     <DisplayName>Veracolate 5 mg delayed release tablet</DisplayName>
#     <Refills>1</Refills>
#     <DaysSupply>3</DaysSupply>
#     <Schedule>0</Schedule>
#     <NoSubstitution xsi:nil="true"/>
#     <Notes>asd</Notes>
#     <DateLastFilled xsi:nil="true"/>
#     <DateWritten>1900-01-01T05:00:00</DateWritten>
#     <DateReported>2016-08-10T11:55:54.69</DateReported>
#     <PharmacyId xsi:nil="true"/>
#     <MonographPath>HTMLICONS/d01015a1.htm</MonographPath>
#     <DrugClassification>gastrointestinal agents</DrugClassification>
#     <NDC>38485040210</NDC>
#     <RxCUI>668696</RxCUI>
#     <Strength>5 mg</Strength>
#     <Route>oral</Route>
#     <PrescriberUserId>0</PrescriberUserId>
#     <DateInactive xsi:nil="true"/>
#     <LexiGenProductId>3890</LexiGenProductId>
#     <LexiDrugSynId>88222</LexiDrugSynId>
#     <LexiSynonymTypeId>60</LexiSynonymTypeId>
#     <GenericDrugName>bisacodyl</GenericDrugName>
#     <LexiCompDrugId>d01015</LexiCompDrugId>
#     <IsPRN>false</IsPRN>
#   </MedicationListItem>
# </Medications>