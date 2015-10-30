require 'logger'
module ForemanProxmox
  class VirtualmachinesController < ApplicationController
    
    def create_vm
      host = Host.find(params[:id])
      $LOG= Logger.new("/tmp/proxmox_debug.log")
      
      if Virtualmachine.where("host_id = '#{host.id}'").first == nil then
        new_vm = Virtualmachine.new
        
        $LOG.error("creating vm")
        
        if host.params['proxmox_id'] == nil then
          proxmoxserver = Proxmoxserver.where("current = 'true'").first
        else
          proxmoxserver = Proxmoxserver.find(host.params['proxmox_id'])
        end
        
        new_vm.proxmoxserver_id = proxmoxserver.id
        $LOG.error(new_vm.proxmoxserver_id)
        
        if host.params['vmid'] == nil then
          $LOG.error("searching vmid")
          new_vm.get_free_vmid
        else
          new_vm.vmid = host.params['vmid']
        end
        
        $LOG.error(new_vm.vmid)
        new_vm.sockets = host.params['sockets']
        new_vm.cores = host.params['cores']
        new_vm.memory = host.params['memory']
        new_vm.size = host.params['size']
        new_vm.mac = host.mac
        new_vm.host_id = host.id
      
      
        if new_vm.save then
          flash[:notice] = "VM saved in DB"
        else
          flash[:error] = _('Fail')
        end
      end
      
      new_vm = Virtualmachine.where("host_id = '#{host.id}'").first
      
      new_vm.create_qemu
      new_vm.start
      
      redirect_to :back
    end
    
    def start_vm
      host = Host.find(params[:id])
      vm = Virtualmachine.find(host.params['vmid'])
      vm.start
      redirect_to :back
    end
    
    def stop_vm
      host = Host.find(params[:id])
      vm = Virtualmachine.find(host.params['vmid'])
      vm.stop
      redirect_to :back
    end
    
    def reboot_vm
      host = Host.find(params[:id])
      vm = Virtualmachine.find(host.params['vmid'])
      vm.reboot
      redirect_to :back
    end
    
    def delete_vm
      host = Host.find(params[:id])
      vm = Virtualmachine.find(host.params['vmid'])
      vm.delete
      redirect_to :back
    end
    
  end
end
