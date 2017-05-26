class Snomed
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  table_config name: 'v20160301'

  field :conceptId,      type: String
  field :active,         type: Boolean
  field :defaultTerm,    type: String

  index :conceptId
  index :defaultTerm

  has_many :diagnoses

  def self.find_by(part)
    if part.length > 3
      snomeds = where(:conceptId.eq   => (part..(part + 'z' * 25)))
      unless snomeds.any?
        part    = part.capitalize
        snomeds = where(:defaultTerm.eq => (part..(part + 'z' * 100)))
      end
      snomeds
    else
      []
    end
  end

  def to_label
    defaultTerm
  end
end
