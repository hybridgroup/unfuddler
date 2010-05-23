require 'helper'

class TestUnfuddler < Test::Unit::TestCase
  context "an Unfuddler project instance" do
    setup do
      #Unfuddler.authenticate(:username => "user", :password => "", :subdomain => "ticketmaster")
      @project = Unfuddler::Project.find.first
    end

    should "find a ticket" do
      ticket = @project.tickets.first
      assert ticket.is_a?(Unfuddler::Ticket)
    end

    should "be able to create a ticket" do
      # Should return an empty hash on success
      assert @project.ticket.create(:priority => "3", :description => "This is a test ticket made by Unfuddler", :summary => "Test Ticket").empty?
    end

    should "be able to delete the newly created ticket, which should be the last one" do
      # Should return an empty hash on success
      assert @project.tickets.last.delete.empty?
    end
  end
end
