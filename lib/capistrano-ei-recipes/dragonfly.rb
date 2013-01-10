unless Capistrano::Configuration.respond_to?(:instance)
  abort 'capistrano/ext/multistage requires Capistrano 2'
end

Capistrano::Configuration.instance.load do
  namespace :dragonfly do
    desc "Symlink the Rack::Cache files"
    task :symlink, :roles => [:app] do
      run "mkdir -p #{shared_path}/tmp/dragonfly && ln -nfs #{shared_path}/tmp/dragonfly #{release_path}/tmp/dragonfly"
    end
  end

  after 'deploy:update_code', 'dragonfly:symlink'
end
