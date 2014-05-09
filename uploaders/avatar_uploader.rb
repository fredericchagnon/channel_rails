# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base

  # Include RMagick or ImageScience support:
  include CarrierWave::MiniMagick
  include CarrierWave::MimeTypes

  # CONFIGURATION OPTIONS TO SET STORAGE TYPE AND DIRECTORY ARE SET IN 
  # CONFIG/INITIALIZERS/CARRIERWAVE.RB

  # Process files as they are uploaded to 160 by 160 (which is hires version
  # for retina display - will be 80px by 80px on older displays):
  process :resize_to_fill => [160, 160]
  process :convert => 'jpg'
  # Use MIME Types to set the file type
  process :set_content_type

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end
  
  # ******** STUFF BELOW IS DONE IN API/V1/PERSONAS/SET_AVATAR METHOD ********
  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
  def filename
    # @name ||= "#{persona_id}.#{file.extension}" if original_filename.present?
    @name ||= "#{persona_id}.jpg" if original_filename.present?
  end
  
  protected

  def persona_id
    var = :"@#{mounted_as}_persona_id"
    model.instance_variable_get(var) or model.instance_variable_set(var, model.persona.id)
  end

end
