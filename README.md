# dev-recipe

itamae recipe to build my development server.

## supported OS

- CentOS 7.0

## services

- memcached
- chrony (yet another ntpd)
- nginx
- mysqld
- redis-server
- elasticsearch
- fluentd

# Usage

```
# if you don't have 'mycentos7' box, fix Vagrantfile.
$ vagrant up

$ bundle install --path .bundle

# change -i option path for your environment.
$ bundle exec itamae ssh --sudo -h 127.0.0.1 -p 2222 -u vagrant -i ~/.vagrant.d/boxes/mycentos7/0/virtualbox/vagrant_private_key recipe.rb --node-yaml node.yml
```

