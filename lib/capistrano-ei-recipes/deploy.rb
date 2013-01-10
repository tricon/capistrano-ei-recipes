unless Capistrano::Configuration.respond_to?(:instance)
  abort 'capistrano/ext/multistage requires Capistrano 2'
end

Capistrano::Configuration.instance.load do
  namespace :deploy do
    desc "Deploy your application"
    task :default do
      update
      restart
    end

    desc "Setup your git-based deployment app"
    task :setup, :except => { :no_release => true } do
      dirs = [deploy_to, shared_path]
      dirs += shared_children.map { |d| File.join(shared_path, d) }
      run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
      run "git clone #{repository} #{current_path}"
    end

    task :cold do
      update
      migrate
    end

    task :update do
      transaction do
        update_code
      end
    end

    desc "Update the deployed code."
    task :update_code, :except => { :no_release => true } do
      run "cd #{current_path}; git fetch origin; git reset --hard #{branch}"
      finalize_update
    end

    desc "Update the database (overwritten to avoid symlink)"
    task :migrations do
      transaction do
        update_code
      end
      migrate
      assets.precompile
      restart
    end

    task :finalize_update, :except => { :no_release => true } do
      run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)

      # mkdir -p is making sure that the directories are there for some SCM's that don't
      # save empty folders
      run <<-CMD
      rm -rf #{latest_release}/log #{latest_release}/public/system #{latest_release}/tmp/pids &&
      mkdir -p #{latest_release}/public &&
      mkdir -p #{latest_release}/tmp &&
      ln -s #{shared_path}/log #{latest_release}/log &&
      ln -s #{shared_path}/public/system #{latest_release}/public/system &&
      ln -s #{shared_path}/tmp/pids #{latest_release}/tmp/pids
      CMD
    end

    namespace :rollback do
      desc "Moves the repo back to the previous version of HEAD"
      task :repo, :except          => { :no_release => true } do
        set :branch, "HEAD@{1}"
        deploy.default
      end

      desc "Rewrite reflog so HEAD@{1} will continue to point to at the next previous release."
      task :cleanup, :except       => { :no_release => true } do
        run "cd #{current_path}; git reflog delete --rewrite HEAD@{1}; git reflog delete --rewrite HEAD@{1}"
      end

      desc "Rolls back to the previously deployed version."
      task :default do
        rollback.repo
        rollback.cleanup
      end
    end
  end
end