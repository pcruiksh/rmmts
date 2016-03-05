class Expense < ActiveRecord::Base
  belongs_to :house

  validates :frequency_integer, numericality: {only_integer: true}
  validates :frequency_unit, presence: true
  validates_inclusion_of :frequency_unit, in: ["days", "weeks", "months", "years"]
  validates :due_date, presence: true
  validate :due_date_cannot_be_in_the_past

  before_destroy :delete_associated_jobs
  after_save :update_reminder

  def due_date_cannot_be_in_the_past
    if due_date.present? && due_date < Date.today
      errors.add(:due_date, "Due date can't be in the past")
    end
  end

  def update_reminder
    if self.reminder_id && self.due_notification_id
      Delayed::Job.find(self.reminder_id).delete if Delayed::Job.exists?(self.reminder_id)
      Delayed::Job.find(self.due_notification_id).delete
      Delayed::Job.find(self.update_due_date_job_id).delete
      self.update_column(:reminder_id, nil)
      self.update_column(:due_notification_id, nil)
      self.update_column(:update_due_date_job_id, nil)
      self.set_reminder
      return
    end
    if self.update_due_date_job_id
      Delayed::Job.find(self.update_due_date_job_id).delete if Delayed::Job.exists?(self.update_due_date_job_id)
    end
    self.set_reminder
  end

  def set_reminder
    unless self.paid
      ExpenseReminderJob.set(wait_until: (self.due_date - 1.days).to_date.noon).perform_later(self)
      self.update_column(:reminder_id, Delayed::Job.where(queue: :expenses).last.id)
      ExpenseDueNotificationJob.set(wait_until: self.due_date).perform_later(self)
      self.update_column(:due_notification_id, Delayed::Job.where(queue: :expenses).last.id)
    end
    UpdateExpenseDueDateJob.set(wait_until: self.due_date).perform_later(self)
    self.update_column(:update_due_date_job_id, Delayed::Job.where(queue: :expenses).last.id)
  end


  def check_status
    return if !self.recurring?
    update_due_date
    self.update_column(:complete, false)
    self.update_column(:reminder_id, nil)
    self.update_column(:due_notification_id, nil)
    self.update_column(:update_due_date_job_id, nil)
    update_reminder
  end

  def update_due_date
    options = { self.frequency_unit.to_sym => self.frequency_integer }
    self.update_column(:due_date, self.due_date.advance(options))
  end

  def delete_associated_jobs
    if self.reminder_id && self.due_notification_id
      Delayed::Job.find(self.reminder_id).delete if Delayed::Job.exists?(self.reminder_id)
      Delayed::Job.find(self.due_notification_id).delete
      Delayed::Job.find(self.update_due_date_job_id).delete
    end
  end

end