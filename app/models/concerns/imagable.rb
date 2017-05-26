module Imagable
  def basename
    Pathname.new(image.to_s).basename.to_s
  end
end