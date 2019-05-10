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
        @tagging_category_api_instance ||= VSphereAutomation::CIS::TaggingCategoryApi.new(@api_client)
      end

      private def tagging_tag_api_instance
        @tagging_tag_api_instance ||= VSphereAutomation::CIS::TaggingTagApi.new(@api_client)
      end

      # returns the category_id or nil
      def verify_category_id( config_category, category_ids_on_host )
        category_ids_on_host.each do |category_id|
          result = tagging_category_api_instance.get(category_id)
          return result.value.id if config_category == result.value.name
        end
        nil
      end

      def verify_tag_id( config_tag, category_tags)
        category_tags.each do |category_tag|
          result = tagging_tag_api_instance.get(category_tag)
          return result.value.id if config_tag == result.value.name
        end
        nil
      end

      def attach_tags(created_vm, vm_config)
        tags =  vm_config.vm_type.tags

        #tag_assoc_api = VSphereAutomation::CIS::TaggingTagAssociationApi.new(api_client)
        # tag_assoc_info = VSphereAutomation::CIS::CisTaggingTagAssociationAttach.new
        tag_assoc_info.object_id = VSphereAutomation::CIS::VapiStdDynamicID.new
        tag_assoc_info.object_id.id=created_vm.mob_id
        tag_assoc_info.object_id.type='VirtualMachine'

        begin
          category_id_list_on_host = tagging_category_api_instance.list
        rescue VSphereAutomation::ApiError => e
          puts "Exception when calling TaggingCategoryApi->list: #{e}"
        end
        category_ids_on_host = category_id_list_on_host.value

        tags.each do |tag|
          cloud_config_category = tag['category']
          cloud_config_tag = tag['tag']

          # :id=>"urn:vmomi:InventoryServiceCategory:1c909f38-5273-462f-a866-ed11e71247e6:GLOBAL",
          # other information  in  result.value
          # :name=>"test-category", :description=>"neil for test",
          #  :cardinality=>"SINGLE", :associable_types=>[], :used_by=>[]}
          target_category = verify_category_id(cloud_config_category, category_ids_on_host)

          # target_category should not be nil
          #           should support VM associativity
          #           cardinality  => better to group these cate-tags first and then do verify cadinality

          begin
            tag_list_in_category = tagging_tag_api_instance.list_tags_for_category(target_category)
          rescue VSphereAutomation::ApiError => e
            puts "Exception when calling TaggingTagApi->list_tags_for_category: #{e}"
          end

          category_tags = tag_list_in_category.value
          
          # next is find all tags under target target_category.id
          target_tag = verify_tag_id(cloud_config_tag, category_tags)
          tag_assoc_api.attach(target_tag,tag_assoc_info)
        end
      end
    end
  end
end






