class BillingPdf < Prawn::Document

  def initialize(procedures)
    super()
    procedures.each_with_index do |procedure, index|
      text_box procedure.date_of_service.try(:strftime, Date::DATE_FORMATS[:dosespot]) || '',   at: [10,  700 - index * 25], size: 12
      text_box procedure.procedure_code.try(:code) || '',                                       at: [100, 700 - index * 25], size: 12
      text_box procedure.encounter.try(:notes) || '',                                           at: [200, 700 - index * 25], size: 12
      text_box procedure.tooth_table.try(:tooth_num).try(:to_s) || '',                          at: [300, 700 - index * 25], size: 12
      text_box procedure.surface.try(:get_all_true_fields) || '',                               at: [400, 700 - index * 25], size: 12
    end
  end
end