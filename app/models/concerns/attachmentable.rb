module Attachmentable
  def basename
    Pathname.new(file_name.to_s).basename.to_s
  end
end