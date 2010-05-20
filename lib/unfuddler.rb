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

    def request(type, url, data = nil)
      request = eval("Net::HTTP::#{type.capitalize}").new("/api/v1/#{url}", {'Content-type' => "application/xml"})
      request.basic_auth @username, @password

      request.body = data if data
      handle_response(@http.request(request))
    end

    def handle_response(response)
      valid_codes = [201, 200, 302]
      raise "Server returned response code: " + response.code unless valid_codes.include?(response.code.to_i)
      Crack::XML.parse(response.body)
    rescue
      "Can't parse"
    end

    [:get, :put, :post, :delete].each do |method|
      define_method(method) do |url, data = nil|
        request(method, url, data)
      end
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

    def save
      update = self.to_hash.to_xml(:root => "ticket")
      Unfuddler.put("projects/#{self.project_id}/tickets/#{self.id}", update)
    end

    def create(project_id = nil)
      ticket = self.to_hash.to_xml(:root => "ticket")
      Unfuddler.post("projects/#{project_id or self.project_id}/tickets", ticket)
    end

    def delete
      Unfuddler.delete("projects/#{self.project_id}/tickets/#{self.id}")
    end

    class Interacter
      def initialize(project_id)
        @project_id = project_id
      end

      def create(ticket = {})
        ticket = Ticket.new(ticket)
        ticket.create(@project_id)
      end
    end
  end
end
