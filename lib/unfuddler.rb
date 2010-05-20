require 'hashie'
require 'net/http'
require 'crack/xml'
require 'active_support'
require 'active_support/core_ext/hash'

module Unfuddler
  class << self
    attr_accessor :username, :password, :subdomain, :http

    def authenticate(info)
      @username, @password, @subdomain = info[:username], info[:password], info[:subdomain]
      @http = Net::HTTP.new("#{@subdomain}.unfuddle.com", 80)
    end

    #def request(type, url, data = nil)
    def request(type, url, data = nil)
      request = eval("Net::HTTP::#{type.capitalize}").new("/api/v1/#{url}", {'Content-type' => "application/xml"})
      request.basic_auth @username, @password

      request.body = data if data

      @http.request(request)
    end

    def get(url)
      request(:get, url)
    end

    def put(url, data)
      request(:put, url, data)
    end

    def post(url, data)
      request(:post, url, data)
    end
  end

  class Project < Hashie::Mash
    def self.find
      projects = []
      Unfuddler.get("projects.xml")["projects"].each do |project|
        projects << Project.new(project)
      end
      projects
    end

    def tickets
      Ticket.find(self.id)
    end

    def ticket
      Ticket::Interacter.new(self.id)
    end
  end

  class Ticket < Hashie::Mash
    def self.find(project_id)
      tickets = []
      Unfuddler.get("projects/#{project_id}/tickets.xml")["tickets"].each do |project|
        tickets << Ticket.new(project)
      end
      tickets
    end

    def self.create(ticket, project_id)
      ticket = ticket.to_xml(:root => "ticket")
      Unfuddler.post("projects/#{project_id}/tickets", ticket)
    end

    class Interacter
      def initialize(project_id)
        @project_id = project_id
      end

      def create(ticket)
        Ticket.create(ticket, @project_id)
      end
    end
  end
end

