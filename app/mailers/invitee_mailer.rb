class InviteeMailer < ApplicationMailer
  default from: 'no-reply@rsvp.com'

  def invitation_email(event, invitee)
    @event = event
    @invitee = invitee
    mail(to: @invitee.email, subject: @event.name)
  end
end
