class ChoreDueNotificationJob < ActiveJob::Base
  queue_as :chores

  def perform(chore)
    @chore = chore
    if @chore.mate
      notification = @chore.notifications.find_by(mate_id: @chore.mate)
      if notification.email?
        MateMailer.chore_due(@chore, @chore.mate).deliver_later
      end
      if notification.sms?
        @chore.sms_due(@chore.mate)
      end
    else
      @chore.house.mates.each do |mate|
        notification = mate.notifications.find_by(chore_id: @chore.id)
        if notification.email?
          MateMailer.chore_due(@chore, mate).deliver_later
        end
        if notification.sms?
          @chore.sms_due(@chore.mate)
        end
      end
    end
  end

end
