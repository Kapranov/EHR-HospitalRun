require_relative 'helper'

module Patient::Reportable::BySex
  include Patient::Reportable::Helper

  # find_by_sex(String, Range)
  def find_by_sex(sex, created_at_range)
    criterias = []

    criterias << {:gender.eq => sex} if sex.present?
    criterias += add_time_ranges_criteria({created_at: created_at_range})

    criterias.count > 1 ? where(and: criterias) : where(criterias)
  end

  def query_for_sex(query)
    [query[0], query[1..2].all?(&:present?) ? Date.strptime(query[1], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time..Date.strptime(query[2], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time : nil]
  end
end