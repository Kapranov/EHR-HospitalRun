module Diagnos::Reconciliationable
  def self.included base
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods
    def find_referral
      Diagnosis.where(and: [{patient_id: patient_id}, {snomed_id: snomed_id}, {:id.not => id}, {referral: true}])
    end

    def previous_reconciliation
      diagnosis = Diagnosis.where(and: [{patient_id: patient_id}, {referral: false}, {:created_at.lt => created_at}]).last
      diagnosis = Diagnosis.where(and: [{patient_id: patient_id}, {referral: false}]).last if diagnosis == nil || id == diagnosis.id
      diagnosis
    end

    def merge_reconciliation
      diagnoses = find_referral
      diagnoses.order(:updated_at).each do |diagnosis|
        if updated_at < diagnosis.updated_at
          (Diagnosis.fields.keys - [:id, :created_at, :updated_at, :referral, :patient_id, :snomed_id]).each do |field|
            self.method("#{field}=").call(diagnosis.method(field).call)
          end
        end
      end
      self.save
      diagnoses.destroy_all
      self
    end
  end

  module ClassMethods
    def last_reconciliation(patient_id)
      Diagnosis.where(and: [{patient_id: patient_id}, {referral: false}]).last
    end
  end
end