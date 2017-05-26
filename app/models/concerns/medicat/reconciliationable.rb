module Medicat::Reconciliationable
  def self.included base
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods
    def find_referral
      diagnosis_ids = diagnosis.patient.diagnoses.map(&:id)
      Medication.where(and: [{:diagnosis_id.in => diagnosis_ids}, {shorthand: shorthand}, {:id.not => id}, {referral: true}])
    end

    def previous_reconciliation
      diagnosis_ids = diagnosis.patient.diagnoses.map(&:id)
      medication = Medication.where(and: [{:diagnosis_id.in => diagnosis_ids}, {referral: false}, {:created_at.lt => created_at}]).last
      medication = Medication.where(and: [{:diagnosis_id.in => diagnosis_ids}, {referral: false}]).last if medication == nil || id == medication.id
      medication
    end

    def merge_reconciliation
      medications = find_referral
      medications.order(:updated_at).each do |medication|
        if updated_at < medication.updated_at
          (Medication.fields.keys - [:id, :created_at, :updated_at, :referral, :shorthand, :diagnosis_id, :portion_id]).each do |field|
            self.method("#{field}=").call(medication.method(field).call)
          end
        end
      end
      self.save
      medications.destroy_all
      self
    end
  end

  module ClassMethods
    def last_reconciliation(patient_id)
      diagnosis_ids = Patient.find(patient_id).diagnoses.map(&:id)
      Medication.where(and: [{:diagnosis_id.in => diagnosis_ids}, {referral: false}]).last
    end
  end
end