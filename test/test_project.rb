require 'helper'

class TestUnfuddler < Test::Unit::TestCase
  context "a Unfuddler project instance" do
    setup do
      #Unfuddler.subdomain = ""
      #Unfuddler.username = ""
      #Unfuddler.password = ""
      @project = Unfuddler::Project.find(:first)
    end

    should "find a ticket" do
      ticket = @project.tickets.first
      assert ticket.is_a?(Unfuddler::Ticket)
    end

    should "have an account id" do
      assert_not_nil @project.account_id
    end
  end
end
