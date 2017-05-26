Dir["#{Rails.root}/models/concerns/patient/reportable/*.rb"].each {|file| require file }

module Patient::Reportable
  REPORTABLE_CRITERIAS = {
      diagnosis:             { name: 'Problem (Dx)',         method: :find_by_diagnosis },
      medication:            { name: 'Medications (Rx)',     method: :find_by_medication },
      allergy:               { name: 'Medication Allergies', method: :find_by_allergy },
      age:                   { name: 'Age',                  method: :find_by_age },
      sex:                   { name: 'Sex',                  method: :find_by_sex },
      smoking_status:        { name: 'Smoking Status',       method: :find_by_smoking_status },
      race:                  { name: 'Race',                 method: :find_by_race },
      ethnicity:             { name: 'Ethnicity',            method: :find_by_ethnicity },
      preferred_language:    { name: 'Preferred Language',   method: :find_by_preferred_language },
      lab:                   { name: 'Lab Tests & Results',  method: :find_by_lab }
  }

  [:ByAge, :ByAllergy, :ByDiagnosis, :ByEthnicity, :ByLab,
   :ByMedication, :ByPreferredLanguage,
   :ByRace, :BySex, :BySmokingStatus].each do |const|
    include "Patient::Reportable::#{const}".constantize
  end

  Patient::Reportable.constants.find_all{ |const| const.to_s.include? '_CRITERIAS' }.each do |criteria_name|
    # Patient.reportable_criterias => REPORTABLE_CRITERIAS
    define_method criteria_name.to_s.downcase do
      Patient::Reportable.const_get criteria_name
    end
  end

  def reportable_criteria_names
    REPORTABLE_CRITERIAS.values.map{ |criteria| criteria[:name] }
  end

  def find_by_report(report)
    method(REPORTABLE_CRITERIAS.values.find{ |v| v[:name] == report.criteria }[:method])
    .call(*query_for_report(report))
  end

  def find_by_criteria_name(name)
    REPORTABLE_CRITERIAS.find{|_, v| v[:name] == name }
  end

  private

  def query_for_report(report)
    report.query.map!{ |p| p.blank? ? nil : p }
    if REPORTABLE_CRITERIAS.values.map{ |v| v[:name] }.include? report.criteria
      method("query_for_#{REPORTABLE_CRITERIAS.find{ |_, v| v[:name] == report.criteria }[0]}").call(report.query)
    end
  end
end