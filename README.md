# Unfuddler

Unfuddler is a simple Ruby API to Unfuddle's projects and tickets. Primarily made for [ticketmaster](http://github.com/Sirupsen/ticketmaster).

## Usage

Unfuddler.subdomain = "mysubdomain"
Unfuddler.username = "sirup"
Unfuddler.password = "super-seekrit1!"
Unfuddler::Project.find(:first).tickets

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 [Hybrid Group](http://hybridgroup.com). See LICENSE for details.
