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
          result = tagging_tag_api_instance.get(category_tag)  # rescue if error occurs here
          return result.value.id if config_tag == result.value.name
        end
        nil
      end

      def verify_vm_association(target_category_id)
        category_information = tagging_category_api_instance.get(target_category_id)  # rescue if error occurs here
        category_associable_types = category_information.value.associable_types
        return true if category_associable_types.empty?
        return true if category_associable_types.include?("VirtualMachine")
        false
      end

      def attach_tags(created_vm, vm_config)  # may raise failure due to AttachTagToVm.new(api_client) api client error
        require 'pry-byebug'
        binding.pry

        tags =  vm_config.vm_type.tags

        #tag_assoc_api = VSphereAutomation::CIS::TaggingTagAssociationApi.new(api_client)
        # tag_assoc_info = VSphereAutomation::CIS::CisTaggingTagAssociationAttach.new
        tag_assoc_info.object_id = VSphereAutomation::CIS::VapiStdDynamicID.new
        tag_assoc_info.object_id.id = created_vm.mob_id
        tag_assoc_info.object_id.type = 'VirtualMachine'

        begin
        category_id_list_on_host = tagging_category_api_instance.list

        rescue => e2
          if e2.instance_of(VSphereAutomation::ApiError)
            logger.warn("Failed with message: #{e2}. Continue without attaching Tags to VM." )
          else
            puts "Unkonw error, please debug"
          end
          # #<VSphereAutomation::ApiError: Unauthorized> due to authentication step
        end

        if e2.nil?
          category_ids_on_host = category_id_list_on_host.value   # if  this is empty ,

          config_cate = []
          config_tag = [ ]

          tag_hash = {}




          tags.each do |tag|
            cloud_config_category = tag['category']
            cloud_config_tag = tag['tag']
            config_cate <<


          end



          tags.each do |tag|
            cloud_config_category = tag['category']
            cloud_config_tag = tag['tag']

            # :id=>"urn:vmomi:InventoryServiceCategory:1c909f38-5273-462f-a866-ed11e71247e6:GLOBAL",
            # other information  in  result.value
            # :name=>"test-category", :description=>"neil for test",
            #  :cardinality=>"SINGLE", :associable_types=>[], :used_by=>[]}
            target_category_id = verify_category_id(cloud_config_category, category_ids_on_host)

            vm_association = verify_vm_association(target_category_id)
            # target_category should not be nil
            #           should support VM associativity
            #           cardinality  => better to group these cate-tags first and then do verify cadinality
            if vm_association
              begin
                tag_list_in_category = tagging_tag_api_instance.list_tags_for_category(target_category_id)
              rescue VSphereAutomation::ApiError => e
                puts "Exception when calling TaggingTagApi->list_tags_for_category: #{e}"
              end
              category_tags = tag_list_in_category.value
              target_tag = verify_tag_id(cloud_config_tag, category_tags)
              tag_assoc_api.attach(target_tag,tag_assoc_info)
            else
              logger.warn("Tag category '#{cloud_config_category}' is not associated with object type: 'Virtual Machine', skip tagging this category to vm" )
            end
          end # end of
        end
      end
    end
  end
end






