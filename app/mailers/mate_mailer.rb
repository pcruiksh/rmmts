class MateMailer < ApplicationMailer

  def welcome_email(mate)
    @mate = mate
    @homepage = houses_url
    @newhouse = new_house_url
    mail(to: @mate.email, subject: "Welcome to rmmts!")
  end

  def join_house(mate, house)
    @mate = mate
    @house = house
    mail(to: @mate.email, subject: "You've joined a house!")
  end

  def chore_notification(chore, mate)
    @mate = mate
    @chore = chore
    mail(to: @mate.email, subject: "Reminder for #{@chore.name}")
  end
end
