# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'SumoSuggest'
set :repo_url, 'https://luelher:797965@bitbucket.org/sumosuggest/sumosuggest.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/ec2-user/sumosuggest'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc "link config files"
  task :link_config_files do
    on roles(:app) do
      if test("[ -f #{shared_path}/database.yml ]")
        execute :ln, '-s', "#{shared_path}/database.yml", "#{release_path}/config/database.yml"
      else
        puts "No existe archivo database.yml en #{shared_path}"
      end
      if test("[ -f #{shared_path}/secret_token.rb ]")
        execute :ln, '-s', "#{shared_path}/secret_token.rb", "#{release_path}/config/initializers/secret_token.rb"
      else
        puts "No existe archivo database.yml en #{shared_path}"
      end
      # if test("[ -d #{shared_path}/assets ]")
      #   execute :ln, '-s', "#{shared_path}/assets", "#{release_path}/public/assets"
      # else
      #   puts "No existe archivo database.yml en #{shared_path}"
      # end
    end
  end

  desc "compile assets"
  task :compile_assets do
    on roles(:app) do
      within release_path do
        execute :rake, 'assets:precompile'
      end
    end
  end

  desc "bundle install"
  task :bundle_install do
    on roles(:app) do
      within release_path do
        execute 'bundle install'
      end
    end
  end


  after :restart, :clear_cache do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      run "mkdir -p #{release_path}/tmp" unless test("[ -d #{release_path}/tmp ]")
      execute :touch, release_path.join('tmp/restart.txt')
      execute "sudo service apache2 restart"
    end
  end

  after :deploy, :bundle_install
  after :deploy, :link_config_files
  after :deploy, :compile_assets



end
