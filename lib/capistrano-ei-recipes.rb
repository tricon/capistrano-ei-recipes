require 'capistrano-ei-recipes/version'
require 'bundler/capistrano'
require 'capistrano-ei-recipes/helpers'
require 'capistrano-ei-recipes/bundler'
require 'capistrano-ei-recipes/deploy'
require 'capistrano-ei-recipes/dragonfly'
require 'capistrano-ei-recipes/rails'
require 'capistrano-ei-recipes/unicorn'

unless Capistrano::Configuration.respond_to?(:instance)
  abort 'capistrano/ext/multistage requires Capistrano 2'
end

Capistrano::Configuration.instance.load do
  set :default_environment, {
    'LANG' => 'en_US.UTF-8'
  }
  set :stages,         %w(production staging)
  set :default_stage, 'staging'
  require 'capistrano/ext/multistage'

  # User details
  set :user,          'deployer'
  set(:group)         { user }

  # Application details
  set(:application)     { abort "Please specify the name of your application, set :application, 'foo'" }
  set(:runner)          { user }
  set :use_sudo,         false
  set :bundle_without,   [:darwin, :development, :test]
  set :rake,             'bundle exec rake'
  set(:current_path)     { File.join(deploy_to, current_dir) }
  set(:unicorn_pid)      { "#{current_path}/tmp/pids/unicorn.pid" }
  set :whenever_command, 'bundle exec whenever'

  set(:latest_release)   { fetch(:current_path) }
  set(:release_path)     { fetch(:current_path) }
  set(:current_release)  { fetch(:current_path) }

  set(:current_revision)  { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
  set(:latest_revision)   { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
  set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }

  set(:deploy_to) { "/var/www/#{fetch(:application)}" }

  # SCM settings
  set :scm,             'git'
  set(:repository)      { "git@github.com:tricon/#{application}" }
  set(:branch)          { "origin/#{current_git_branch}" }

  # Git settings for Capistrano
  default_run_options[:pty]     = true # needed for git password prompts
  ssh_options[:forward_agent]   = true # use the keys for the person running the cap command to check out the app
end
