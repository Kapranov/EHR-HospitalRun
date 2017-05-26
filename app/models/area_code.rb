class AreaCode
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :code, type: String
  field :city, type: String

  index :code
end