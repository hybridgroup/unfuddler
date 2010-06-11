require 'helper'

class TestUnfuddler < Test::Unit::TestCase
  context "an Unfuddler project" do
    setup do
      Unfuddler.authenticate(:username => "", :password => "", :subdomain => "ticketmaster")
      @project = Unfuddler::Project.find.first
    end

    should "be a project" do
      assert @project.is_a?(Unfuddler::Project)
    end

    should "find a project with name Test" do
      assert_instance_of Unfuddler::Project, Unfuddler::Project.find("testproject")
    end

    should "find a project with name Test" do
      assert_instance_of Unfuddler::Project, Unfuddler::Project["testproject"]
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

    should "create a new ticket" do
      assert @project.ticket.create(:priority => "3", :summary => "TestTicket", :description => "This is a description for a test ticket.").empty?
    end

    should "find tickets by summary and description" do
      assert_instance_of Unfuddler::Ticket, @project.tickets.find(:summary => "TestTicket", :description => "This is a description for a test ticket.").first
    end

    context "with new ticket instance" do
      setup do
        @ticket = @project.tickets.last
      end

      should "have right summary" do
        assert_equal "TestTicket", @ticket.summary
      end

      should "be a ticket" do
        assert @ticket.is_a?(Unfuddler::Ticket)
      end

      should "close the last ticket with a resolution" do
        assert @ticket.close!(:resolution => "fixed", :description => "Fixed it").empty?
      end

      should "have new resolution description" do
        assert_equal "Fixed it", @ticket.resolution_description
      end

      #should "delete the last ticket" do
        # Should return an empty hash on success
      #  assert @ticket.delete.empty?
      #end
    end
  end
end
