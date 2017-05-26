class Loinc
  include NoBrainer::Document

  extend Searchable

  field :loinc_num,              type: String
  field :long_common_name,       type: String

  self_search [:loinc_num, :long_common_name], :loinc

  index :loinc_num
  index :long_common_name

  def description
    "#{long_common_name} (#{loinc_num})"
  end
end
