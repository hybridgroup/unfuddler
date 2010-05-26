%w{
  hashie
  net/http
  crack/xml
  active_support
  active_support/core_ext/hash
}.each {|lib| require lib}

module Unfuddler
  class << self
    attr_accessor :username, :password, :subdomain, :http

    def authenticate(info)
      @username, @password, @subdomain = info[:username] || info["username"], info[:password] || info["password"], info[:subdomain] || info["subdomain"]
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
    end

    [:get, :put, :post, :delete].each do |method|
      define_method(method) do |url, data = nil|
        request(method, url, data)
      end
    end
  end

  class Project < Hashie::Mash
    def self.find(name = nil)
      projects = []
      Unfuddler.get("projects.xml")["projects"].each do |project|
        projects << Project.new(project)
      end

      if name 
        right_project = nil
        projects.each do |project|
          right_project = project if project.short_name == name.to_s
        end
        return right_project
      end

      projects
    end

    def self.[](name = nil)
      self.find(name)
    end

    def tickets(argument = nil)
      Ticket.find(self.id, argument)
    end

    def ticket
      Ticket::Interacter.new(self.id)
    end
  end

  class Ticket < Hashie::Mash
    # Find tickets associated with a project.
    #
    # Required argument is project_id, which is the id
    # of the project to search for tickets.
    #
    # Optional argument is argument, which searches the tickets
    # to match the keys in the argument. e.g.
    #   Ticket.find(:status => "new")
    # Returns all tickets with status "new"
    def self.find(project_id, arguments = nil)
      tickets = []
      Unfuddler.get("projects/#{project_id}/tickets.xml")["tickets"].each do |project|
        tickets << Ticket.new(project)
      end
      
      if arguments
        specified_tickets = []
        
        # Check each ticket if all the expected values pass, return all
        # tickets where everything passes in an array
        tickets.each do |ticket|
          matches = 0
          arguments.each_pair do |method, expected_value|
            matches += 1 if ticket.send(method) == expected_value
          end
          
          specified_tickets << ticket if matches == arguments.length
        end
        
        return specified_tickets
      end

      tickets
    end

    # Save ticket
    #
    # Optional argument is what to update if the ticket object is not altered
    def save(update = nil)
      update = self.to_hash.to_xml(:root => "ticket") unless update
      Unfuddler.put("projects/#{self.project_id}/tickets/#{self.id}", update)
    end
    
    # Create a ticket
    #
    # Optional argument is project_id
    def create(project_id = nil)
      ticket = self.to_hash.to_xml(:root => "ticket")
      Unfuddler.post("projects/#{project_id or self.project_id}/tickets", ticket)
    end
    
    [:closed!, :new!, :unaccepted!, :reassigned!, :reopened!, :accepted!, :resolved!].each do |method|
      # Fix method names, e.g. #reassigned! => #reassign!
      length = method[0..-3] if method == :closed!
      length = method[0..-2] if [:new!, :resolved!].include?(method)
      
      define_method((length || method[0..-4]) + "!") do |resolution = {}|
        name = method[0..-2] # No "!"
        update = {:status => name}
        
        if resolution
          # The API wants resolution-description for a resolutions description,
          # to make it more user-friendly, we convert this automatically
          resolution[:"resolution-description"] = resolution.delete(:description)
          update.merge!(resolution)
        end
        
        update = update.to_xml(:root => "ticket")
        save(update)
      end
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
