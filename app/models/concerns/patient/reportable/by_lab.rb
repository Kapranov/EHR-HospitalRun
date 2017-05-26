require_relative 'helper'

module Patient::Reportable::ByLab
  include Patient::Reportable::Helper

  # find_by_lab(String, Range, Range, Range)
  def find_by_lab(part, test_resported_at_range, tested_at_range, created_at_range)
    criterias = []
    patient_critarias = []

    if part.present?
      test_orders = TestOrder.find_test_order_by(part)
      patient_critarias << {:id.in => LabOrder.where(:id.in => test_orders.map(&:lab_order_id)).map(&:patient_id)} if test_orders.any?
    end

    criterias += add_time_ranges_criteria({test_resported_at: test_resported_at_range,
                                           tested_at: tested_at_range,
                                           created_at: created_at_range})

    patient_critarias << if criterias.any?
                          lab_results = criterias.count > 1 ? LabResult.where(and: criterias) : LabResult.where(criterias)
                          {:id.in => lab_results.map(&:patient_id)}
                        else
                          {}
                        end
    patient_critarias.count > 1 ? where(and: patient_critarias) : where(patient_critarias)
  end

  def query_for_lab(query)
    [query[0],
     query[1..2].all?(&:present?) ? Date.strptime(query[1], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time..Date.strptime(query[2], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time : nil,
     query[3..4].all?(&:present?) ? Date.strptime(query[3], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time..Date.strptime(query[4], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time : nil,
     query[5..6].all?(&:present?) ? Date.strptime(query[5], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time..Date.strptime(query[6], Date::DATE_FORMATS[:frontend_date]).to_s(:db).to_time : nil]
  end
end