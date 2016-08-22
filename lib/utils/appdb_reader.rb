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

    class << self
      def vaproviders_from_appdb
        response = HTTParty.post(APPDB_PROXY_URL, body: APPDB_REQUEST_FORM)
        providers = response.success? ? response.parsed_response : nil
        providers ? providers['broker']['reply']['appdb']['provider'] : []
      end

      def vaprovider_sizes(vaprovider)
        templates = [vaprovider['template']].flatten.compact
        templates.collect do |template|
          next if template['resource_name'].blank?
          {
            id: template['resource_name'],
            name: template['resource_name'].split('#').last,
            memory: template['main_memory_size'],
            vcpu: template['logical_cpus'],
            cpu: template['physical_cpus']
          }
        end.compact
      end

      def vaprovider_appliances(vaprovider)
        images = [vaprovider['image']].flatten.compact
        images.collect do |image|
          appl = image_appliance(image)
          next unless appl

          vo = vaprovider_appliances_vo(vaprovider, appl, image)

          {
            id: image['va_provider_image_id'],
            name: appl['title'].gsub(/\[.+\]/, ''),
            mpuri: image['mp_uri'],
            vo: vo
          }
        end.compact
      end

      private

      def image_appliance(image)
        return nil if image['va_provider_image_id'].blank? || image['mp_uri'].blank?

        response = HTTParty.get("#{image['mp_uri'].chomp('/')}/json")
        response.success? ? response.parsed_response : nil
      end

      def vaprovider_appliances_vo(vaprovider, appl, image)
        appl['sites'].each do |site|
          site['services'].each do |service|
            next unless service['id'] == vaprovider['id']

            service['vos'].each do |vo|
              return vo['name'] if vo['occi']['id'] == image['va_provider_image_id']
            end
          end
        end

        'unknown'
      end
    end
  end
end
