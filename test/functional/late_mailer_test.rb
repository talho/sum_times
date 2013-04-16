require 'test_helper'

class LateMailerTest < ActionMailer::TestCase
  test "late" do
    mail = LateMailer.late
    assert_equal "Late", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
