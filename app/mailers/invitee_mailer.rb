require 'rqrcode'
require 'rqrcode_png'
include ApplicationHelper

class InviteeMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)
  default from: 'no-reply@rsvp.com'

  def invitation_email(event, invitee)
    @event = event
    @invitee = invitee
    mail(to: @invitee.email, subject: @event.name)
  end

  def invitation_response(event, invitee)
    @event = event
    @invitee = invitee
    @qrcode = RQRCode::QRCode.new("#{ domain }#{ update_arrival_invitee_path(@invitee) }")
    @qrcode_png = @qrcode.to_img.resize(200, 200).save("public/images/qrcode-#{ @invitee.id }.png")
    # to_data_url
    mail(to: @invitee.email, subject: @event.name)
  end
end
