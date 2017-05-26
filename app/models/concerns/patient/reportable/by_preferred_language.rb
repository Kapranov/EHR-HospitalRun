require_relative 'helper'

module Patient::Reportable::ByPreferredLanguage
  include Patient::Reportable::Helper

  # find_by_preferred_language(String, Range)
  def find_by_preferred_language(preferred_language, created_at_range)
    criterias = []

    criterias << {preferred_language: preferred_language} if preferred_language.present?
    criterias += add_time_ranges_criteria({created_at: created_at_range})

    criterias.count > 1 ? where(and: criterias) : where(criterias)
  end

  def query_for_preferred_language(query)
    [query[0], query[1..2].all?(&:present?) ? Date.strptime(query[1], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time..Date.strptime(query[2], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time : nil]
  end
end