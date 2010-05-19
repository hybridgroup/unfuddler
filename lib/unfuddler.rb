require 'hashie'
require 'net/http'
require 'crack/xml'
require 'xmlsimple'

module Unfuddler
  class << self
    attr_accessor :username, :password, :subdomain, :http

    def authenticate(info)
      @username, @password, @subdomain = info[:username], info[:password], info[:subdomain]
      @http = Net::HTTP.new("#{info[:subdomain]}.unfuddle.com")
    end

    def request(type, url, data = nil)
      # Use Module#const_get (error before thus not using it now)
      request = eval("Net::HTTP::#{type.capitalize}").new("/api/v1/#{url}.xml", {'Content-type:' => 'application/xml'})
      request.basic_auth @username, @password

      if [:put, :post].include?(type) and data
        request.body = data
      end

      response = @http.request(request)
      Crack::XML.parse(response.body)
    end

    def get(url)
      request(:get, url)
    end

    def put(url, data)
      request(:put, url, data)
    end
  end

  class Project < Hashie::Mash
    def self.find
      projects = []
      Unfuddler.get("projects")["projects"].each do |project|
        projects << Project.new(project)
      end
      projects
    end

    def tickets
      Ticket.find(self.id)
    end
  end

  class Ticket < Hashie::Mash
    def self.find(project_id)
      tickets = []
      Unfuddler.get("projects/#{project_id}/tickets")["tickets"].each do |project|
        tickets << Ticket.new(project)
      end
      tickets
    end

    def save
      ticket = XmlSimple.new("rootname" => "ticket")
      Unfuddler.put("projects/#{project_id}/tickets/#{self.id}", ticket.xml_out(self.to_hash))
    end
  end
end
