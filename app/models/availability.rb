class Availability
  include NoBrainer::Document

  field :role,       type: String
  field :available,  type: Boolean

  belongs_to :permission

  default_scope order :role
end
