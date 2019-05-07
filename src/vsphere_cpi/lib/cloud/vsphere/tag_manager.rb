require 'cloud/vsphere/logger'
require 'vsphere-automation-cis'
require 'vsphere-automation-vcenter'


# "tags": [
#     {
#         "category": "cata_1",
#         "tag": "tag_1"
#     },
#     {
#         "category": "cata_2",
#         "tag": "tag_1"
#     }
# ]
#

module VSphereCloud
  class TagManager
    include Logger

    attr_writer :tag_category, :tag_name

    def initialize( )

    #@host = @host


      # Authentication part
      configuration = VSphereAutomation::Configuration.new.tap do |config|
        config.host='192.168.111.142'
        config.username='administrator@vsphere.local'
        config.password='Admin!23'
        config.scheme='https'
        config.verify_ssl=false
        config.verify_ssl_host=nil

      end


      @api_client = VSphereAutomation::ApiClient.new(configuration)
      api_client.default_headers['Authorization'] = configuration.basic_auth_token

      session_api = VSphereAutomation::CIS::SessionApi.new(api_client)
      session_id = session_api.create('').value

      api_client.default_headers['vmware-api-session-id'] = session_id




    end







    def attach_tags(created_vm, tags)
      # tags is a array of  Hashes
      # # Sample to Attach a Tag of Given Category to a Virtual Machine
      tags.each do |tag|
        @tag_category = tag['category']
        @tag_name = tag['tag']

        # attach tag
        # def attach tag( )
        @tag_assoc_api = VSphereAutomation::CIS::TaggingTagAssociationApi.new(@api_client)
        @tag_assoc_info = VSphereAutomation::CIS::CisTaggingTagAssociationAttach.new
        @tag_assoc_info.object_id = VSphereAutomation::CIS::VapiStdDynamicID.new
        @tag_assoc_info.object_id.id='vm-122' # this should be the
        tag_assoc_info.object_id.type='VirtualMachine'
        tag_assoc_api.attach('urn:vmomi:InventoryServiceTag:7b128a4f-cd1d-4dee-93d6-0054ef67615f:GLOBAL',
                             )


      end
    end

  end
end