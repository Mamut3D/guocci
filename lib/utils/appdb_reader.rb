require 'httparty'

module Utils
  # Please burn in hell dear rubocop
  # Best Regards
  # Your Mama
  # (fat)
  class AppdbReader
    APPDB_PROXY_URL = 'https://appdb.egi.eu/api/proxy'.freeze
    APPDB_REQUEST_FORM = 'version=1.0&resource=broker&data=%3Cappdb%3Abroker%20xmlns%3Axs%3D%22http%3A%2F%2Fwww.w3.org'\
                         '%2F2001%2FXMLSchema%22%20xmlns%3Axsi%3D%22http%3A%2F%2Fwww.w3.org%2F2001%2FXMLSchema-instanc'\
                         'e%22%20xmlns%3Aappdb%3D%22http%3A%2F%2Fappdb.egi.eu%2Fapi%2F1.0%2Fappdb%22%3E%3Cappdb%3Arequ'\
                         'est%20id%3D%22vaproviders%22%20method%3D%22GET%22%20resource%3D%22va_providers%22%3E%3Cappdb'\
                         '%3Aparam%20name%3D%22listmode%22%3Edetails%3C%2Fappdb%3Aparam%3E%3C%2Fappdb%3Arequest%3E%3C%'\
                         '2Fappdb%3Abroker%3E'.freeze

    APPDB_REQUEST_ALL_IMAGES = 'https://appdb-pi.egi.eu/rest/1.0/sites?listmode=details&flt=%2B%3Dsite.supports%3A1%20'\
                               '%2B%3Dsite.hasinstances%3A1%0A'.freeze

    class << self

      #TODO refactor
      def appliances
        response = HTTParty.get(APPDB_REQUEST_ALL_IMAGES)
        if response.success?
          response = response.parsed_response

          services = response['appdb']['site'].collect do |site|
            [site['service']].flatten.collect do |service|
              {
                service_id: service['id'],
                site_id: site['id'],
                service: service
              } if service['type'] == 'occi'
            end
          end.flatten.compact

          services.select! { |service| service[:service].key? ('image')}

          appliances = services.collect do |service|
            {
              site_id: service[:site_id],
              service_id: service[:service_id],
              appliance: get_appliances(service[:service]['image']),
            }
          end
        else
          nil
        end
      end

      #TODO refactor and finnish
      def sites_and_flavours
        response = HTTParty.get(APPDB_REQUEST_ALL_IMAGES)
        if response.success?
          response = response.parsed_response
          sites = response['appdb']['site'].collect do |site|
            [site['service']].flatten.collect do |service|
              {
                siteid: site['id'],
                name: site['name'],
                country: site['country']['isocode'],
                service_id: service['id'],
                template: filter_template([service['template']].flatten)
              } if (service['type'] == 'occi')
            end
          end.flatten.compact
          #sites.select! { |site| !site[:template].blank?}
          return sites
        else
          nil
        end
      end

      def sites_old_method
        response = HTTParty.get(APPDB_REQUEST_ALL_IMAGES)
        if response.success?
          response = response.parsed_response
          sites = response['appdb']['site'].collect do |site|
            [site['service']].flatten.collect do |service|
              {
                site_id: site['id'],
                name: site['name'],
                country: site['country']['isocode'],
                endpoint: service['occi_endpoint_url'],
                service_id: service['id']
              } if service['type'] == 'occi'
            end
          end.flatten.compact
        else
          nil
        end
      end


      def appliances_old_method
        response = HTTParty.get(APPDB_REQUEST_ALL_IMAGES)
        if response.success?
          response = response.parsed_response

          sites = response['appdb']['site'].collect do |site|
            site['service'] = [site['service']].flatten
          end.flatten

          sites.select! { |site| site['type'] == 'occi' }
          images = sites.collect { |site| site['image']}.flatten.compact

          images.collect do |image|
            image['occi'] = [image['occi']].flatten.compact
            image['occi'].collect do |occi_image|
              if (occi_image.key? ('vo')) #&& (occi_image['vo'].key? ('name'))
                voname = occi_image['vo']['name']
                image_id = occi_image['id'].split('os_tpl#')[1]
              else
                image_id = ''
                void = ''
              end
              {
                #image_global_id: image['id'],
                id: image_id,
                name: image['application']['name'],
                mpuri: image['mpuri'],
                vo: voname
              }
            end
          end.flatten
        else
          nil
        end
      end

      private

      def filter_template(templates)
        templates.collect do |template|
          {
            #template: template,
            resource_id: Base64.strict_encode64(template['group_hash']),
            name: template['resource_name'],
            memory: template['main_memory_size'],
            vcpu: template['logical_cpus'],
            cpu: template['physical_cpus']
          } unless template['group_hash'].blank?
        end.flatten.compact
      end

      def get_appliances(images)
        images = [images].flatten.compact
        images.collect do |image|
          image['occi'] = [image['occi']].flatten.compact
          image['occi'].collect do |occi_image|
            if (occi_image.key? ('vo'))
              voname = occi_image['vo']['name']
              image_id = occi_image['id'].split('os_tpl#')[1]
            else
              image_id = ''
              void = ''
            end
            {
              id: image_id,
              name: image['application']['name'],
              mpuri: image['mpuri'],
              vo: voname
            }
          end
        end.flatten
      end
    end
  end
end
