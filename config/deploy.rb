set :stages, %w(production)
set :default_stage, "production"
require 'capistrano/ext/multistage'

set :application, "sumtimes"
set :repository,  "git://github.com/talho/sum_times.git"
set :scm, :git

set :deploy_via, :remote_cache
set :use_sudo, false
set :rails_env, 'production'

set :rvm_ruby_string, '1.9.3'
require "rvm/capistrano"
require 'capistrano-unicorn'
require "bundler/capistrano"

namespace :deploy do
  task :set_symlinks do
    run "if [ -f #{shared_path}/unicorn/production.rb ]; then rm #{release_path}/config/unicorn/production.rb; ln -fs #{shared_path}/unicorn/production.rb #{release_path}/config/unicorn/production.rb; fi"
    run "ln -fs #{shared_path}/database.yml #{release_path}/config/database.yml"
  end
end

after 'deploy:update_code', 'deploy:set_symlinks'
after 'deploy:restart', 'unicorn:reload' # app IS NOT preloaded
after 'deploy:restart', 'unicorn:restart'  # app preloaded
