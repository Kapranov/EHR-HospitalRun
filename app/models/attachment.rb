class Attachment
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps
  include CarrierWave::NoBrainer
  include Attachmentable

  mount_uploader :file_name, FileUploader

  belongs_to :amendment
end
