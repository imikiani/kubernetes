# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "geerlingguy/debian10"
  config.ssh.insert_key = false
  config.vm.provider "virtualbox"
  config.vm.synced_folder '.', '/vagrant', disabled: true

  # Define three VMs with static private IP addresses.
  boxes = [
    { :name => "storage",       :ip => "172.16.16.50",  :cpu => 1,   :memory => 1024},
    { :name => "loadbalancer",  :ip => "172.16.16.100", :cpu => 1,   :memory => 1024},
    { :name => "kmaster1",      :ip => "172.16.16.101", :cpu => 2,   :memory => 2048},
    { :name => "kmaster2",      :ip => "172.16.16.102", :cpu => 2,   :memory => 2048},
    { :name => "kworker1",      :ip => "172.16.16.201", :cpu => 1,   :memory => 2048}
  ]

  # Configure each of the VMs.
  boxes.each_with_index do |opts, index|
    config.vm.define opts[:name] do |config|
      config.vm.hostname = opts[:name] + ".cluster.test"
      config.vm.network :private_network, ip: opts[:ip]


      config.vm.provider :virtualbox do |v|
        v.memory =  opts[:memory]
        v.cpus = opts[:cpu]
        v.linked_clone = true
        v.customize ['modifyvm', :id, '--audio', 'none']
      end


      # Provision all the VMs using Ansible after last VM is up.
      if index == boxes.size - 1
        config.vm.provision "ansible" do |ansible|
          ansible.compatibility_mode = "2.0"
          ansible.playbook = "playbook.yml"
          ansible.inventory_path = "inventory"
          ansible.limit = "all"
        end
      end
    end
  end

end