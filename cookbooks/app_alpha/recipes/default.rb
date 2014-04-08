#
# Cookbook Name:: app_alpha
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

deploy '/apps/alpha' do
  repo 'https://github.com/liftopia/myInterview.git'
  migrate true
  migration_command 'bundle exec rake db:migrate'
  symlinks {}
  before_migrate do
    Dir.chdir(release_path) do
      directory "/apps/alpha/shared/config"
      directory "/apps/alpha/shared/log"
      cookbook_file "/apps/alpha/shared/config/database.yml"
      system('bundle --deployment --path /tmp/bundles')
      system('mysqladmin create my_interview_development || echo "Already Created"')
    end
  end
  before_restart do
    Dir.chdir(release_path) do
      system('killall -9 ruby1.9.1')
    end
  end

  restart_command 'bundle exec rackup -D'
end

user 'liftopian'
