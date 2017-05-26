class TestOrder
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  extend  Searchable

  field :code,     type: String
  field :test,     type: String
  field :result,   type: String
  field :units,    type: String
  field :flag,     type: String
  field :range,    type: String

  belongs_to :lab_order
  belongs_to :image_order

  self_search [:code, :test], :test_order, [:all]
end