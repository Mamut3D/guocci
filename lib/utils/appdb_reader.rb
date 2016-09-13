require 'httparty'

module Utils
  # Please burn in hell dear rubocop
  # Best Regards
  # Your Mama
  # (fat)
  class AppdbReader
    APPDB_PROXY_URL = 'https://appdb.egi.eu/api/proxy'.freeze
    APPDB_REQUEST_ALL = 'https://appdb-pi.egi.eu/rest/1.0/sites?listmode=details&flt=%2B%3Dsite.supports%3A1%20'\
                        '%2B%3Dsite.hasinstances%3A1%0A'.freeze

    class << self
      def appdb_raw_request
        HTTParty.get(APPDB_REQUEST_ALL)
      end

      def all(options = {})
        response = options[:appdb_raw] || appdb_raw_request
        if response.success?
          response = response.parsed_response
          response['appdb']['site'].collect do |site|
            [site['service']].flatten.collect do |service|
              {
                id: "#{site['id']}:#{service['id']}",
                name: site['name'],
                country: site['country']['isocode'],
                endpoint: service['occi_endpoint_url'],
                site_id: site['id'],
                service_id: service['id'],
                flavours: filter_flavour([service['template']].flatten),
                appliances: get_appliances(service['image'])
              } if service['type'] == 'occi'
            end
          end.flatten.compact
        end
      end

      private

      def filter_flavour(flavours)
        flavours.collect do |flavour|
          {
            id: Base64.strict_encode64(flavour['resource_name']),
            name: flavour['resource_name'],
            memory: flavour['main_memory_size'],
            vcpu: flavour['logical_cpus'],
            cpu: flavour['physical_cpus']
          } unless flavour['resource_name'].blank?
        end.flatten.compact
      end

      def get_appliances(images)
        images = [images].flatten.compact
        images.collect do |image|
          image['occi'] = [image['occi']].flatten.compact
          image['occi'].collect do |occi_image|
            if occi_image.key? 'vo'
              voname = occi_image['vo']['name']
              image_id = occi_image['id'].split('os_tpl#')[1]
            else
              image_id = ''
              voname = ''
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
