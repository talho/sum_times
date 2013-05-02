#SumTimes

[![Build Status](https://travis-ci.org/talho/sum_times.png)](https://travis-ci.org/talho/sum_times)

##Purpose

SumTimes is an exception-based time tracking and scheduling tool intended for small teams and businesses operating under
flex time schedules. The intent is to build a simple, flexible way to generate timesheets for businesses that are too
small for larger trackers and don't need by-hour tracking.

##Installation

Sumtimes is offered as a ready-to-deploy server suite.

####Requirements:
* RVM
* Ruby 1.9.3 or 2.0.0
* Postgresql (using postgres arrays, making this db dependent)
* Bundler gem

####Installation:

    git clone git://github.com/talho/sum_times.git
    cd sum_times
    bundle install --deployment

Change database.yml to point to your local database and config/unicorn/production.rb to indicate your server preferences then:

    rake db:create db:migrate
    rails c
    Admin.create(email: 'admin_email@example.com', password: 'PasswordExample1')
    exit
    unicorn -c ./config/unicorn/production.rb -E production -D

And now you can log into the site and create normal users.

##Customization

Currently SumTimes is set with TALHO's values defaulted. To set your own values, before these are optioned off to .yml (feature coming soon),
fork this repository, customize with your own values. Once forked you can use capistrano to deploy your project by modifying config/deploy/production.rb.examle

##Usage

Users create schedules, request leaves, and can view the status of the office. At the end of the month admin generates timesheets and
updates the current leave balances via Accruals.

More complete manual coming soon.

##Extending

Fork this repository, make changes, submit a pull request.

---

Copyright (c) 2013, TALHO
All rights reserved.

Licensed under modified BSD to disallow commercial re-hosting.
