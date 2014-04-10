#
# Cookbook Name:: app_beta
# Recipe:: default
#
# Copyright 2014, Liftopia
#
# All rights reserved - Do Not Redistribute
#
#

package 'ruby1.9.3'
package 'libsasl2-dev'
package 'libmysqlclient-dev'
package 'nodejs'
package 'mongodb'
package 'redis-server'

gem_package 'bundler'

directory '/apps'

deploy '/apps/beta' do
  repo 'https://github.com/liftopia/myInterview.git'
  migrate true
  migration_command 'bundle exec rake db:migrate'
  symlinks {}
  before_migrate do
    Dir.chdir(release_path) do
      directory "/apps/beta/shared/config"
      directory "/apps/beta/shared/log"
      cookbook_file "/apps/beta/shared/config/database.yml"
      system('bundle --deployment --path /tmp/bundles')
      system('mysqladmin create my_interview_development || echo "Already Created"')
    end
  end
  before_restart do
    execute "restarting app_beta" do
      command 'kill -9 $(cat /apps/beta/shared/rack.pid)'
      only_if "test -f /apps/beta/shared/rack.pid"
    end
  end

  restart_command 'bundle exec rackup -p 9293 -D -P /apps/beta/shared/rack.pid'
end

user 'liftopian'
