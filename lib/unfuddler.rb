require 'active_resource'

module Unfuddler
  def self.subdomain=(subdomain)
    ActiveResource::Base.site = "http://#{subdomain}.unfuddle.com/api/v1/"
  end

  def self.username=(username)
    ActiveResource::Base.user = username
  end

  def self.password=(password)
    ActiveResource::Base.password = password
  end

  class Project < ActiveResource::Base
    def tickets
      Ticket.find(:all, :from => "/projects/#{id}/tickets")
    end

    def self.all
      find(:all, :from => "/projects.xml")
    end
  end

  class Ticket < ActiveResource::Base
    self.prefix = "/tickets"
  end
end
