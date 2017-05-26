require_relative 'helper'

module Patient::Reportable::ByRace
  include Patient::Reportable::Helper

  # find_by_race(String, Range)
  def find_by_race(race, created_at_range)
    criterias = []

    criterias << {Patient.races[race] => true} if Patient.races[race].present?
    criterias += add_time_ranges_criteria({created_at: created_at_range})

    criterias.count > 1 ? where(and: criterias) : where(criterias)
  end

  def query_for_race(query)
    [query[0],
     query[1..2].all?(&:present?) ? Date.strptime(query[1], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time..Date.strptime(query[2], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time : nil]
  end
end