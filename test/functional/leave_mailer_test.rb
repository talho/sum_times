require 'test_helper'

class LeaveMailerTest < ActionMailer::TestCase
  test "request" do
    mail = LeaveMailer.request
    assert_equal "Request", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "accept" do
    mail = LeaveMailer.accept
    assert_equal "Accept", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "deny" do
    mail = LeaveMailer.deny
    assert_equal "Deny", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
