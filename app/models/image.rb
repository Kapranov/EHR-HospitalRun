class Image
  include NoBrainer::Document
  include CarrierWave::NoBrainer
  include Imagable

  mount_uploader :image, ImageUploader
end
