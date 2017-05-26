module Allergy::Reconciliationable
  def self.included base
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods
    def find_referral
      Allergy.where(and: [{patient_id: patient_id}, {note: note}, {:id.not => id}, {referral: true}])
    end

    def previous_reconciliation
      allergy = Allergy.where(and: [{patient_id: patient_id}, {referral: false}, {:created_at.lt => created_at}]).last
      allergy = Allergy.where(and: [{patient_id: patient_id}, {referral: false}]).last if allergy == nil || id == allergy.id
      allergy
    end

    def merge_reconciliation
      allergies = find_referral
      allergies.order(:updated_at).each do |allergy|
        if updated_at < allergy.updated_at
          (Allergy.fields.keys - [:id, :created_at, :updated_at, :referral, :patient_id, :note]).each do |field|
            self.method("#{field}=").call(allergy.method(field).call)
          end
        end
      end
      self.save
      allergies.destroy_all
      self
    end
  end

  module ClassMethods
    def last_reconciliation(patient_id)
      Allergy.where(and: [{patient_id: patient_id}, {referral: false}]).last
    end
  end
end