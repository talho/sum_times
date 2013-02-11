set :stages, %w(production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, "Sumtimes"
set :repository,  "git@github.com:talho/sum_times.git"
set :scm, :git

set :deploy_via, :remote_cache
set :rails_env, 'production'

set :rvm_ruby_string, '1.9.3'
require "rvm/capistrano"
require 'capistrano-unicorn'

namespace :deploy do
  task :symlink do
    run "if [ -f #{shared_path}/unicorn/production.rb ] then rm #{release_path}/config/unicorn/production.rb; ln -fs #{shared_path}/unicorn/production.yml #{release_path}/config/unicorn/production.yml"
  end
end

after 'deploy:update_code', 'deploy:symlink'
after 'deploy:restart', 'unicorn:reload' # app IS NOT preloaded
after 'deploy:restart', 'unicorn:restart'  # app preloaded
