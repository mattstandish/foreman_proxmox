require 'logger'
module ForemanProxmox
  module HostExtensions
    extend ActiveSupport::Concern
	
    included do
      #execute callbacks	
    end
    
    
    

    # create or overwrite instance methods...
    def destroy
        vm = Virtualmachine.where("host_id = #{self.id}").first
        vm.delete_virtualmachine
        super
    end
    
    def create
      
		super
		
		new_vm = Virtualmachine.new
		
        new_vm.sockets = self.params['sockets']
        new_vm.cores = self.params['cores']
        new_vm.memory = self.params['memory']
        new_vm.size = self.params['size']
        if self.params['vmid'] == nil then
			    new_vm.get_free_vmid
		    else
          new_vm.vmid = self.params['vmid']
        end
        if self.params['name'] == nil
          new_vm.name = self.shortname
        else
          new_vm.name = self.params['name']
        end
        new_vm.mac = self.mac
        new_vm.host_id = self.id
        new_vm.save
        
        
        if new_vm.create_virtualmachine(self)
          if new_vm.create_harddisk
            new_vm.start
          end
        end
        
        
    end
    
    
    


    module ClassMethods
      # create or overwrite class methods...
      
    end
  end
end
