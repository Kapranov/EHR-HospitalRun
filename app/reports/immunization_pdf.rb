class ImmunizationPdf < Prawn::Document

  def initialize(immunizations)
    super()
    immunizations.each_with_index do |immunization, index|
      text_box immunization.vaccine.try(:name) || '',                                            at: [10,  700 - index * 25], size: 12
      text_box immunization.name.try(:to_s) || '',                                               at: [200, 700 - index * 25], size: 12
      text_box immunization.administered_at.try(:strftime, Date::DATE_FORMATS[:dosespot]) || '', at: [300, 700 - index * 25], size: 12
      text_box immunization.administered_by.try(:to_label) || '',                                at: [400, 700 - index * 25], size: 12
    end
  end
end