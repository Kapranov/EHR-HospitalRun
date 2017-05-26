class LoincComment
  include NoBrainer::Document

  field :loinc_num,          type: String
  field :loinc_num_map,      type: String
  field :comment,            type: String

  index :loinc_num
  index :loinc_num_map
end
