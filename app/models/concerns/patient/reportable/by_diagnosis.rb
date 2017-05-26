require_relative 'helper'

module Patient::Reportable::ByDiagnosis
  include Patient::Reportable::Helper

  DIAGNOSIS_CRITERIAS = {before: 'Added on or Before', after: 'Added on or After', between: 'Added Between'}

  # find_by_diagnoses(String, Time, Time, {'Added Between' => (Time..Time)}, Boolean)
  #                                  ..., {'Added on or Before' => Time}, ...
  def find_by_diagnosis(part, start_at, stop_at, created_at_criteria, check_med_existence = false)
    criterias = []

    if part.present? && part.length > 3
      snomeds = Snomed.find_by(part)
      criterias << {:snomed_id.in => snomeds.any? ? snomeds.map(&:id) : []}
    end

    criterias << {:start_date.ge => start_at.beginning_of_day} if start_at.present?
    criterias << {:stop_date.le  => stop_at.end_of_day}  if stop_at.present?

    if created_at_criteria.present? && created_at_criteria.is_a?(Hash) && created_at_criteria.values[0].present?
      case created_at_criteria.keys.first
        when DIAGNOSIS_CRITERIAS[:before]
          criterias << {:created_at.le => created_at_criteria.values.first}
        when DIAGNOSIS_CRITERIAS[:after]
          criterias << {:created_at.ge => created_at_criteria.values.first}
        when DIAGNOSIS_CRITERIAS[:between]
          criterias += add_time_ranges_criteria({created_at: created_at_criteria.values.first})
      end
    end

    patient_critarias = if criterias.any?
      diagnoses = criterias.count > 1 ? Diagnosis.where(and: criterias) : Diagnosis.where(criterias)
      diagnoses = diagnoses.find_all{ |diag| diag.medications.any? } if check_med_existence
      {:id.in => diagnoses.map(&:patient_id)}
    else
      {}
    end
    where(patient_critarias)
  end

  def query_for_diagnosis(query)
    [query[0]] + query[1..2].map{ |param| param.present? ? Date.strptime(param, Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time : nil } + if query[3] == DIAGNOSIS_CRITERIAS[:between]
      query += [nil] if query.length < 6
      query[3..5].all?(&:present?) ? [{query[3] => Date.strptime(query[4], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time..Date.strptime(query[5], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time}] : [nil]
    else
      query[3..4].all?(&:present?) ? [{query[3] => Date.strptime(query[4], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time}] : [nil]
    end
  end
end