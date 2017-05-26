module ImageCollectionable
  def self.included(base)
    base.class_eval do
      field :images, type: Array, default: []

      before_destroy :destroy_images
    end
  end

  def images?
    images.present? && images.any?
  end

  def all_images
    images? ? Image.where(:id.in => images) : []
  end

  def add_image(image)
    update(images: self.images << image.id)
  end

  private

  def destroy_images
    all_images.destroy_all if images?
  end
end