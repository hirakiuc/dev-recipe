# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.synced_folder '../data', '/vagrant_data', disabled: true

  config.vm.provider 'virtualbox' do |vb|
    vb.memory = '1024'
  end

  config.vm.define 'sakura' do |host|
    host.vm.box = 'mycentos7'
    host.vm.network 'private_network', ip: '192.168.33.15'
  end
end
