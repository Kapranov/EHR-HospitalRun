require_relative 'helper'

module Patient::Reportable::ByAge
  include Patient::Reportable::Helper

  AGE_CRITERIAS = {eq: '=', more: '>/=', less: '</=', between: 'Between'}

  # find_by_age({'=' => Int}, (Time..Time), (Time..Time))
  # find_by_age({'Between' => (Int..Int)}, ...
  def find_by_age(age_criteria, birth_range, created_at_range)
    criterias = []

    if age_criteria.present? && age_criteria.is_a?(Hash) && age_criteria.values[0].present?
      birth_at = Time.new(Time.now.year - age_criteria.values.first.to_i) if age_criteria.keys.first != AGE_CRITERIAS[:between]
      case age_criteria.keys.first
        when AGE_CRITERIAS[:eq]
          criterias << {:birth.ge => birth_at.beginning_of_year}
          criterias << {:birth.le => birth_at.end_of_year}
        when AGE_CRITERIAS[:more]
          criterias << {:birth.le => birth_at.end_of_year}
        when AGE_CRITERIAS[:less]
          criterias << {:birth.ge => birth_at.beginning_of_year}
        when AGE_CRITERIAS[:between]
          range = age_criteria.values.first
          if range.present? && range.is_a?(Range)
            birth_to_at   = Time.now - range.first.year
            birth_from_at = Time.now - range.last.year
            criterias << {:birth.ge => birth_from_at.beginning_of_year}
            criterias << {:birth.le => birth_to_at.end_of_year}
          end
      end
    end

    criterias += add_time_ranges_criteria({birth: birth_range, created_at: created_at_range})

    criterias.count > 1 ? where(and: criterias) : where(criterias)
  end

  def query_for_age(query)
    if query[0] == AGE_CRITERIAS[:between]
      query += [nil] if query.length < 7
      age_criteria     = query[0..2].all?(&:present?) ? {query[0] => query[1].to_i..query[2].to_i} : nil
      birth_range      = query[3..4].all?(&:present?) ? Date.strptime(query[3], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time..Date.strptime(query[4], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time : nil
      created_at_range = query[5..6].all?(&:present?) ? Date.strptime(query[5], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time..Date.strptime(query[6], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time : nil
    else
      age_criteria     = (query[0].present? && query[1].present?) ? {query[0] => query[1].to_i} : nil
      birth_range      = query[2..3].all?(&:present?) ? Date.strptime(query[2], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time..Date.strptime(query[3], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time : nil
      created_at_range = query[4..5].all?(&:present?) ? Date.strptime(query[4], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time..Date.strptime(query[5], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time : nil
    end
    [age_criteria, birth_range, created_at_range]
  end
end