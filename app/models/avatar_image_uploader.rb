class AvatarImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  
  storage :fog
 
  version :web do
    process :resize_to_fill => [152, 152]
  end
 
end