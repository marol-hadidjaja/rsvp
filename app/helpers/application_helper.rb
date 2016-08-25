module ApplicationHelper
  def domain
    if Rails.env == 'development'
      'http://localhost:3000'
    elsif Rails.env == 'production'
      'http://onlineinvitation.mainpage.io'
    end
  end

  def email_image_tag(image, **options)
    attachments[image.file_file_name] = File.read(image.file.path)
    image_tag attachments[image.file_file_name].url, **options
  end
end
