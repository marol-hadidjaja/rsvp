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
    @qrcode = RQRCode::QRCode.new("http://192.168.1.4:3000#{ update_arrival_invitee_path(@invitee) }")
    @qrcode_png = @qrcode.to_img.resize(90, 90)
    mail(to: @invitee.email, subject: @event.name)
  end
end
