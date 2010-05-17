require 'httparty'
require 'hashie'

module Unfuddler
  include HTTParty
  format :json

  def self.authenticate(info)
    self.base_uri "#{info[:subdomain]}.unfuddle.com/api/v1"
    self.basic_auth info[:username], info[:password]
  end

  class Project < Hashie::Mash
    attr_accessor :attributes 

    def self.find
      projects = []
      Unfuddler.get("/projects.json").each do |project|
        projects << Project.new(project)
      end
      projects
    end
    
    def tickets
      Ticket.find(:all, {:project_id => id})
    end
  end

  class Ticket < Hashie::Mash
    def self.find(which, options = {})
      tickets = []
      Unfuddler.get("/projects/#{options[:project_id]}/tickets.json").each do |ticket|
        tickets << Ticket.new(ticket)
      end
      tickets
    end

    def create
      query = {:body => {:description => "Hello World"}}
      Unfuddler.post("/projects/#{project_id}/tickets.json", query)
    end
  end
end

