class LateMailer < ActionMailer::Base
  default from: "sumtimes@talho.org"

  def late(late)
    @late = late
    @supervisors = @late.user.supervisors

    mail to: @supervisors.map(&:email),
         subject: "#{@late.user.name} is running late"
  end
end
