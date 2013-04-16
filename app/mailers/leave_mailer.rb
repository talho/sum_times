class LeaveMailer < ActionMailer::Base
  default from: "sumtimes@talho.org"

  def req(leave)
    @leave = leave
    @supervisors = @leave.user.supervisors

    mail to: @supervisors.map(&:email),
         subject: "#{@leave.user.name} has requested leave"
  end

  def accept(leave, sup)
    @leave = leave
    @supervisor = sup
    mail to: @leave.user.email,
         subject: "Your leave, starting #{ I18n.l @leave.start_date, :format => :long } has been approved"
  end

  def deny(leave, sup)
    @leave = leave
    @supervisor = sup
    mail to: @leave.user.email,
         subject: "Your leave, starting #{ I18n.l @leave.start_date, :format => :long } has been denied"
  end
end
