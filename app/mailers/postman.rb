class Postman < ActionMailer::Base
  default :from => '"Playtime" <jesters.playtime@gmail.com>'

  def casting_notification(show, editor)
    @show, @editor = [show, editor]
    @players = show.players
    mail to: show.player_emails,
         cc: "fauxparse@gmail.com",
         subject: "Cast for #{show.date.strftime("%e/%m/%y")}"
  end
end
