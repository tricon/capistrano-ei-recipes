unless Capistrano::Configuration.respond_to?(:instance)
  abort 'capistrano/ext/multistage requires Capistrano 2'
end

Capistrano::Configuration.instance.load do
  namespace :bundler do
    task :create_symlink, :roles => :app do
      shared_dir = File.join(shared_path, 'bundle')
      release_dir = File.join(current_release, 'vendor')
      run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
    end
  end

  after 'deploy:setup', 'bundler:create_symlink'
end
