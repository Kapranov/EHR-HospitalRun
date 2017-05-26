require_relative 'helper'

module Patient::Reportable::BySmokingStatus
  include Patient::Reportable::Helper

  # find_by_smoking_status(String, Range, Range)
  def find_by_smoking_status(smoking_status, effective_range, created_at_range)
    criterias = []

    criterias << {status: smoking_status} if smoking_status.present?

    criterias += add_time_ranges_criteria({effective_from: effective_range}) if effective_range.present?
    criterias += add_time_ranges_criteria({created_at: created_at_range})    if created_at_range.present?

    patient_critarias = if criterias.any?
                          statuses = criterias.count > 1 ? SmokingStatus.where(and: criterias) : SmokingStatus.where(criterias)
                          {:id.in => statuses.map(&:patient_id)}
                        else
                          {}
                        end
    where(patient_critarias)
  end

  def query_for_smoking_status(query)
    [query[0],
    query[1..2].all?(&:present?) ? Date.strptime(query[1], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time..Date.strptime(query[2], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time : nil,
    query[3..4].all?(&:present?) ? Date.strptime(query[3], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time..Date.strptime(query[4], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time : nil]
  end
end