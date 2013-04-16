class TimesheetMailer < ActionMailer::Base
  default from: "sumtimes@talho.org"

  ##
  #   Mails all users in the system that their timesheet is ready to be submitted
  ##
  def generated
    mail to: User.all.map(&:email),
         subject: 'Your timesheet is now ready'
  end

  def submitted(timesheet)
    @timesheet = timesheet
    mail to: @timesheet.user.supervisors.map(&:email),
         subject: "#{@timesheet.user.name} has submitted a timesheet"
  end

  def rejected(timesheet, sup)
    @supervisor = sup
    @timesheet = timesheet
    mail to: @timesheet.user.email,
         subject: "Your timesheet was rejected"
  end

  def reminder(timesheet)
    @timesheet = timesheet
    mail to: @timesheet,
         subject: "Reminder, submit your timesheet!"
  end
end
