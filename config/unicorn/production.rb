# ------------------------------------------------------------------------------
# Sample rails 3 config
# ------------------------------------------------------------------------------

# Set your full path to application.
app_path = "/home/talho/sumtimes/current"

# Set unicorn options
worker_processes 4
preload_app true
timeout 180

# Spawn unicorn master worker for user apps (group: apps)
user 'talho', 'talho'

# Fill path to your app
working_directory app_path

listen "#{app_path}/tmp/sockets/unicorn.sock", :backlog => 64

# Should be 'production' by default, otherwise use other env
rails_env = ENV['RAILS_ENV'] || 'production'

# Log everything to one file
stderr_path "log/unicorn.log"
stdout_path "log/unicorn.log"

# Set master PID location
pid "#{app_path}/tmp/pids/unicorn.pid"

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
