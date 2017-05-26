module Patient::Reportable::ByMedication
  def find_by_medication(part, start_at, stop_at, created_at_criteria)
    find_by_diagnosis(part, start_at, stop_at, created_at_criteria, true)
  end
end