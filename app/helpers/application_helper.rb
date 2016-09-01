module ApplicationHelper
  def domain
    if Rails.env == 'development'
      'http://localhost:3000'
    elsif Rails.env == 'production'
      'http://onlineinvitation.mainpage.io'
    end
  end

  def email_image_tag(image, **options)
    if image.is_a? Image
      attachments[image.file_file_name] = File.read(image.file.path)
      image_tag attachments[image.file_file_name].url, **options
    else
      attachments['qrcode.png'] = { content: image, mime_type: 'image/png', encoding: 'base64' }
      binding.pry
      image_tag attachments['qrcode.png'], **options
    end
  end
end
