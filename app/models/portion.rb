class Portion
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :drug,            type: String
  field :dose,            type: String
  field :instruction,     type: String

  has_many :medications

  def drug_with_dose
    "#{drug} #{dose}"
  end
end
