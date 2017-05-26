class AppSetting
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

  field :version,       type: String
end
