require 'shellwords'
# TODO: disable selinux

### rbenv
include_recipe 'rbenv::system'

execute 'add rbenv config' do
  command %(
echo '
export RBENV_ROOT=/usr/local/rbenv
export PATH="${RBENV_ROOT}/bin:${PATH}"
eval "$(rbenv init -)"
' >> /etc/bashrc
  )
  not_if 'grep RBENV_ROOT /etc/bashrc'
end

### memcached
package 'memcached'

service 'memcached' do
  action [:enable, :start]
end

template '/etc/sysconfig/memcached' do
  source 'templates/memcached.erb'
  notifies :restart, 'service[memcached]'
end

### chrony (yet another ntpd)
package 'chrony'

template '/etc/chrony.conf' do
  source 'templates/chrony.conf.erb'
  notifies :restart, 'service[chronyd]'
  owner 'chrony'
  group 'chrony'
  mode '644'
end

service 'chronyd' do
  action [:enable, :start]
end

### nginx
template '/etc/yum.repos.d/nginx.repo' do
  source 'templates/nginx.repo.erb'
end

package 'nginx'

service 'nginx' do
  action [:enable, :start]
end

# TODO: add nginx config

### mysqld
execute 'install mysql-community-release rpm' do
  command 'rpm -ivh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm'
  not_if 'rpm -q mysql-community-release'
end

package 'mysql-community-server'

service 'mysqld' do
  action [:enable, :start]
end

### redis-server
package 'epel-release'

package 'redis'

service 'redis' do
  action [:enable, :start]
end

template '/etc/redis.conf' do
  source 'templates/redis.conf.erb'
  mode '600'
  owner 'redis'
  group 'redis'
  notifies :restart, 'service[redis]'
end

### elasticsearch
package 'java-1.8.0-openjdk'

execute 'import elasticsearch GPG-KEY' do
  command 'rpm --import https://packages.elasticsearch.org/GPG-KEY-elasticsearch'
  not_if 'rpm -q elasticsearch'
end

template '/etc/yum.repos.d/elasticsearch.repo' do
  source 'templates/elasticsearch.repo.erb'
end

template '/etc/yum.repos.d/logstash.repo' do
  source 'templates/logstash.repo.erb'
end

package 'elasticsearch'

service 'elasticsearch' do
  action [:enable, :start]
end

package 'logstash'

# TODO: elasticsearch config

### kibana4
# FIXME: kibana4 user
directory '/opt/kibana4' do
  action :create
  owner node.kibana.owner
  group node.kibana.group
end

execute 'download kibana4...' do
  command 'curl https://download.elastic.co/kibana/kibana/kibana-4.0.2-linux-x64.tar.gz > /tmp/kibana-4.0.2-linux-x64.tar.gz'
  not_if 'ls -1 /opt/kibana4 | grep bin'
end

execute 'extract kibana4' do
  command 'tar xf /tmp/kibana-4.0.2-linux-x64.tar.gz -C /opt/kibana4 --strip=1'
  not_if 'ls -1 /opt/kibana4 | grep bin'
end

execute 'chown kibana4' do
  command "chown -R #{node.kibana.owner}:#{node.kibana.group} /opt/kibana4"
  not_if "ls -l /opt/kibana4 | grep #{node.kibana.owner}"
end

### td-agent
execute 'install td-agent' do
  command 'curl -L http://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.sh | sh'
  not_if 'rpm -q td-agent'
end

service 'td-agent' do
  action [:enable, :start]
end

# TODO: install fluentd plugins
# TODO: fluentd config
