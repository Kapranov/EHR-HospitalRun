class TriggerCategory
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  def self.categories
    [:Problem, :Medications, :Allergies, :Demographics, :'Lab Results', :'Vital Signs']
  end

  field :category,         type: Enum,       in: self.categories,    default: self.categories.first

  has_one    :trigger
  belongs_to :provider
end
