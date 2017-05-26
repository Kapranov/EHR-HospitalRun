module FakerHelpers

  class << self

    def sample_image(image_name = nil)
      File.open(Rails.root.join('spec/support/images/avatars', avatar_name(image_name)))
    end

    def sample_image_name
      "avatar#{(1..11).to_a.sample}.jpg"
    end

    private

    def avatar_name(image_name)
      image_name.present? ? image_name : "avatar#{(1..11).to_a.sample}.jpg"
    end
  end
end