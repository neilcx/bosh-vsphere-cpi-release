require 'cloud/vsphere/logger'
require 'vsphere-automation-cis'
require 'vsphere-automation-vcenter'

module  VSphereCloud
  module TaggingTag
    class AttachTagToVm

      include Logger

      def initialize(api_client)
        @api_client = api_client
      end

      private def tag_assoc_api
        @tag_assoc_api ||= VSphereAutomation::CIS::TaggingTagAssociationApi.new(@api_client)
      end

      private def tag_assoc_info
        @tag_assoc_info ||= VSphereAutomation::CIS::CisTaggingTagAssociationAttach.new
      end

      private def tagging_category_api_instance
        @tagging_category_api_instance ||= VSphereAutomation::CIS::TaggingCategoryApi.new(api_client)
      end

      def verify_category_id( tag_category, category_ids )
        tagging_category_api_instance = VSphereAutomation::CIS::TaggingCategoryApi.new(api_client)
        category_ids.each do |category_id|
          result = tagging_category_api_instance.get(category_id)
          return result.value if tag_category == result.value.name
        end
        nil
      end

      def attach_tags(created_vm, vm_config)
        require 'pry-byebug'
        binding.pry
        tags =  vm_config.vm_type.tags

        #tag_assoc_api = VSphereAutomation::CIS::TaggingTagAssociationApi.new(api_client)
        # tag_assoc_info = VSphereAutomation::CIS::CisTaggingTagAssociationAttach.new
        tag_assoc_info.object_id = VSphereAutomation::CIS::VapiStdDynamicID.new
        tag_assoc_info.object_id.id=created_vm.mob_id
        tag_assoc_info.object_id.type='VirtualMachine'

        begin
          tagging_categories = tagging_category_api_instance.list
        rescue VSphereAutomation::ApiError => e
          puts "Exception when calling TaggingCategoryApi->list: #{e}"
        end

        category_ids = tagging_categories.value



        tags.each do |tag|

          require 'pry-byebug'
          binding.pry

          tag_category = tag['category']
          tag_name = tag['tag']

          # {:id=>"urn:vmomi:InventoryServiceCategory:1c909f38-5273-462f-a866-ed11e71247e6:GLOBAL",
          #  :name=>"test-category", :description=>"neil for test",
          #  :cardinality=>"SINGLE", :associable_types=>[], :used_by=>[]}
          #
          target_id = verify_category_id(tag_category, category_ids)

          # target_id should not be nil
          #           should support VM associativity
          #           cardinality





          tag_assoc_api.attach('urn:vmomi:InventoryServiceTag:6e49baa3-b8c2-43f9-8faf-4e8177d4e1a3:GLOBAL',tag_assoc_info
          )
        end
      end
    end
  end
end






