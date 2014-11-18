# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version '>= 1.5.2'
Vagrant.configure('2') do |config|
  config.vm.hostname = 'chef-huginn'
  config.vm.box = 'chef/ubuntu-14.04'
  config.vm.network :private_network, ip: '10.2.2.20'
  #config.vm.box = "precise64-cloud.2013-06-25"
  #config.vm.box_url = "https://s3.amazonaws.com/kabam-vagrant-boxes/precise64-cloud.2013-06-25.box"

  config.omnibus.chef_version = :latest
  config.berkshelf.enabled = true

  config.vm.provider :virtualbox do |vb|
    vb.cpus = 2
    vb.memory = 2048
  end

  config.vm.provision :chef_solo do |chef|
    #chef.log_level = :debug
    chef.json = {

    }

    chef.run_list = [
      'recipe[huginn::default]',
    ]
    chef.custom_config_path = '.vagrant-solo.rb'
  end
end
