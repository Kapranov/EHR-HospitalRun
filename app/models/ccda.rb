class Ccda
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :identification,         type: Boolean,    default: true
  field :contact_information,    type: Boolean,    default: true
  field :basic_information,      type: Boolean,    default: true
  field :encounter_diagnoses,    type: Boolean,    default: true
  field :immunizations,          type: Boolean,    default: true
  field :cognitive_status,       type: Boolean,    default: true
  field :functional_status,      type: Boolean,    default: true
  field :reason_for_referral,    type: Boolean,    default: true
  field :discharge_instructions, type: Boolean,    default: true
  field :smoking_status,         type: Boolean,    default: true
  field :problems_dx,            type: Boolean,    default: true
  field :medications,            type: Boolean,    default: true
  field :medication_allergies,   type: Boolean,    default: true
  field :laboratory,             type: Boolean,    default: true
  field :vital,                  type: Boolean,    default: true
  field :care_plan,              type: Boolean,    default: true
  field :procedures,             type: Boolean,    default: true
  field :care_team_members,      type: Boolean,    default: true

  belongs_to :patient

  def self.identification_fields
    [:first_name, :middle_name, :last_name, :birth, :age, :gender, :id, :active]
  end

  def self.contact_information_fields
    [:race, :ethnicity, :preferred_language]
  end

  def self.basic_information_fields
    [{ provider:         ->(patient){ patient.created_by.try(:to_label) },                name: 'PROVIDER:'},
     { practice_name:    ->(patient){ patient.created_by.try(:business_name) },           name: 'PRACTICE NAME:'},
     { practice_address: ->(patient){ patient.created_by.try(:location).try(:to_label) }, name: 'PRACTICE ADDRESS:' },
     { practice_phone:   ->(patient){ patient.created_by.try(:primary_phone_to_s) },      name: 'PRACTICE PHONE:'}]
  end

  def self.encounter_diagnoses_fields
    [{encounter_diagnoses: ->(patient){ patient.diagnoses.map{ |diag| diag.try(:snomed).try(:to_label) }.compact }}]
  end

  def self.immunizations_fields
    [{immunizations: ->(patient){ patient.immunizations.map(&:to_label).compact }}]
  end

  def self.cognitive_status_fields
    [{cognitive_status: nil}]
  end

  def self.functional_status_fields
    [{functional_status: nil}]
  end

  def self.reason_for_referral_fields
    [{reason_for_referral: nil}]
  end

  def self.discharge_instructions_fields
    [{discharge_instructions: nil}]
  end

  def self.smoking_status_fields
    [{smoking_status: ->(patient){ patient.smoking_statuses.map(&:to_label).compact }}]
  end

  def self.problems_dx_fields
    [{problems_dx: ->(patient){ patient.diagnoses.map(&:to_label).compact }}]
  end

  def self.medications_fields
    [{medications: ->(patient){ patient.medications.map(&:to_label).compact }}]
  end

  def self.medication_allergies_fields
    [{medication_allergies: ->(patient){ patient.allergies.map(&:to_label).compact }}]
  end

  def self.laboratory_fields
    [{laboratory: ->(patient){ patient.lab_orders.map(&:to_label).compact }}]
  end

  def self.vital_fields
    [{vital: ->(patient){ patient.encounters.map{ |encount| encount.try(:vital).try(:to_label) }.compact }}]
  end

  def self.care_plan_fields
    [{care_plan: nil}]
  end

  def self.procedures_fields
    [{procedures: ->(patient){ patient.encounters.map(&:to_label).compact }}]
  end

  def self.care_team_members_fields
    [{care_team_members: nil}]
  end

  def to_xml
    Nokogiri::XML::Builder.new do |xml|
      xml.patient {
        block_names.each do |block_name|
          Ccda.method("#{block_name}_fields").call.each do |field|
            if field.is_a? Symbol
              xml.send(field, patient.method(field).call)
            else
              values = field.values.first.try(:call, patient)
              if values.is_a? Array
                xml.send(field.keys.first.to_s.pluralize) { values.each { |v| xml.send(field.keys.first.to_s.singularize, v) }}
              else
                xml.send(field.keys.first, values)
              end
            end
          end
        end
      }
    end.to_xml
  end

  def value_of(field)
    if field.is_a? Symbol
      patient.method(field).call # :id
    else
      field.values.first.try(:call, patient) # {medications: ->(patient){ patient.medications.map(&:to_label).compact }}
    end
  end

  def self.patient_info_fields
    [[{'FIRST:'     => :first_name},
     {'DOB:'        => :birth_to_s},
     {'PATIENT ID:' => :id},
     {'RACE:'       => :race}],
    [{'MIDDLE:'     => :middle_name},
     {'AGE:'        => :age},
     {'STATUS:'     => :status},
     {'ETHNICITY:'  => :ethnicity}],
    [{'LAST:'       => :last_name},
     {'SEX:'        => :gender},
     {''            => nil},
     {'PREFERRED LANGUAGE:' => :preferred_language}
     ]]
  end

  private

  def block_names(strict = false)
    Ccda.fields.keys.reject{ |field| [:id, :created_at, :updated_at, :patient_id].include?(field) || (strict && !self.method(field).call) }
  end
end