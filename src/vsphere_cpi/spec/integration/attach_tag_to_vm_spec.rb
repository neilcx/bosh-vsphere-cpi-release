require 'integration/spec_helper'



describe 'Tagging tag to vm' do

  let(:network_spec) do
    {
        'static' => {
            'ip' => "169.254.1.#{rand(4..254)}",
            'netmask' => '255.255.254.0',
            'cloud_properties' => { 'name' => @vlan },
            'default' => ['dns', 'gateway'],
            'dns' => ['169.254.1.2'],
            'gateway' => '169.254.1.3'
        }
    }
  end

  # Question here, can we simulate 2 cloud properties, one for default and the other for large , and How to implement it ?
  let(:vm_type) do
    {
      'ram' => 512,
      'disk' => 2048,
      'cpu' => 1,
      'tags' => [ { 'category' => 'test-category', 'tag' => 'test-tag-1'} ] #, { 'category' => 'cata_2', 'tag' => 'tag_1'} ]
    }

  end

  describe 'When creating a new vm' do
    it 'create the new vm and attached a tag to it' do
      begin
        test_vm_id = @cpi.create_vm(
            'agent-007',
            @stemcell_id,
            vm_type,
            network_spec,
            [],
            {}
        )

        require 'pry-byebug'
        binding.pry

      ensure
        #delete_vm(@cpi, test_vm_id)
      end

    end

  end

end
