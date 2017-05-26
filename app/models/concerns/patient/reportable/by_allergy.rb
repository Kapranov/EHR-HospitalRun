require_relative 'helper'

module Patient::Reportable::ByAllergy
  include Patient::Reportable::Helper

  ALLERGY_CRITERIAS = {by_type: 'By allergen type', by_level: 'By severity level', by_onset: 'By onset at'}

  # find_by_allergy({'By allergen type' => :Drug}, Time, Time)
  def find_by_allergy(allergy_criteria, start_at, created_at)
    criterias = []

    if allergy_criteria.present? && allergy_criteria.is_a?(Hash)
      case allergy_criteria.keys.first
        when ALLERGY_CRITERIAS[:by_type]
          criterias << {allergen_type: allergy_criteria.values.first}
        when ALLERGY_CRITERIAS[:by_level]
          criterias << {severity_level: allergy_criteria.values.first}
        when ALLERGY_CRITERIAS[:by_onset]
          criterias << {onset_at: allergy_criteria.values.first}
      end
    end

    criterias += add_time_ranges_criteria({start_date: start_at.beginning_of_day..start_at.end_of_day})     if start_at.present?
    criterias += add_time_ranges_criteria({created_at: created_at.beginning_of_day..created_at.end_of_day}) if created_at.present?

    patient_critarias = if criterias.any?
      allergies = criterias.count > 1 ? Allergy.where(and: criterias) : Allergy.where(criterias)
      {:id.in => allergies.map(&:patient_id)}
    else
      {}
    end
    where(patient_critarias)
  end

  def query_for_allergy(query)
    [query[0..1].all?(&:present?) ? {query[0] => query[1]} : nil] +
    [query[2].present? ? Date.strptime(query[2], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time : query[2]] +
    [query[3].present? ? Date.strptime(query[3], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time : query[3]]
  end
end