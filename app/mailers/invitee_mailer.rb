class InviteeMailer < ApplicationMailer
  default from: 'no-reply@rsvp.com'

  def invitation_email()
    mail(to: 'marol.ichigo@gmail.com', subject: 'test email')
  end
end
