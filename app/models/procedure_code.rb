class ProcedureCode
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :code,                             type: Text
  field :class1,                           type: Integer
  field :nomenclature,                     type: Text
  field :discriptor,                       type: Text
  field :class2,                           type: Integer
  field :service_category,                 type: String
  field :discriptor_category,              type: Text
  field :subcategory,                      type: Text
  field :discriptor_subcategory,           type: Text
  field :sub_subcategory,                  type: Text
  field :discriptor_sub_subcategory,       type: Text

  index :code
  index :nomenclature

  has_one :procedure

  def to_label
    "#{code} #{nomenclature}"
  end
end