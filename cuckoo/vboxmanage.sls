# Let's you enable rdp on all vmcloak vm-s. By default is not executed on highstate ie requires manual state.apply cuckoo.vboxmanage
modifyvm_rdp:
  cmd.run:
    - name: VBoxManage modifyvm "Win7_64bit_node1" --vrde on --vrdeport 9001 --vrdeaddress=0.0.0.0 --accelerate3d off --accelerate2dvideo on --vrdeauthtype null --vrdeauthlibrary null --vrdemulticon on --vrdereusecon on --vrdevideochannel off
    - runas: {{ salt['pillar.get']('cuckoo:user', 'cuckoo') }}
