require 'helper'

class TestUnfuddler < Test::Unit::TestCase
  context "an Unfuddler project instance" do
    setup do
      Unfuddler.authenticate(:username => "", :password => "", :subdomain => "ticketmaster")
      @project = Unfuddler::Project.find.first
    end

    should "be a project" do
      assert @project.is_a?(Unfuddler::Project)
    end

    should "have authentication information" do
      assert Unfuddler.subdomain.is_a?(String)
      assert Unfuddler.username.is_a?(String)
      assert Unfuddler.password.is_a?(String)
    end

    should "find new tickets assosicated with self" do
      tickets = @project.tickets(:status => "new")
      assert tickets.is_a?(Array)
      assert tickets.last.is_a?(Unfuddler::Ticket)
    end

    context "with a ticket instance" do
      setup do
        @ticket = @project.tickets.last
      end

      should "be a ticket" do
        assert @ticket.is_a?(Unfuddler::Ticket)
      end

      should "close the last ticket with a resolution" do
        assert @ticket.close!(:resolution => "fixed", :description => "Fixed it").empty?
      end

      should "reopen the last ticket" do
        assert @ticket.reopen!
      end

      should "delete the last ticket" do
        # Should return an empty hash on success
        assert @ticket.delete.empty?
      end
    end
  end
end
