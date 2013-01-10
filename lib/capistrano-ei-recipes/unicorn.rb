unless Capistrano::Configuration.respond_to?(:instance)
  abort 'capistrano/ext/multistage requires Capistrano 2'
end

Capistrano::Configuration.instance.load do
  namespace :deploy do
    desc "Zero-downtime restart of Unicorn"
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "kill -s USR2 `cat #{unicorn_pid}`"
    end

    desc "start unicorn"
    task :start, :roles => :app, :except => { :no_release => true } do
      run "cd #{current_path} && bundle exec unicorn_rails -c #{current_path}/config/unicorn-#{rails_env}.rb -E #{rails_env} -D"
    end

    desc "stop unicorn"
    task :stop, :roles => :app, :except => { :no_release => true } do
      run "kill `cat #{unicorn_pid}`"
    end

    desc "graceful stop unicorn"
    task :graceful_stop, :roles => :app, :except => { :no_release => true } do
      run "kill -s QUIT `cat #{unicorn_pid}`"
    end
  end
end
