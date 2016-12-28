class Instances < Base
  def list(site_id, cert)
   occi_client(endpoint(site_id), cert)
   computes = @client.describe (Occi::Infrastructure::Compute.new.kind.type_identifier)
   computes.collect! do |cmpt|
      {
        id: cmpt.location,
        name: (cmpt.title || cmpt.hostname),
        #ip: first_address(cmpt)
        user_data: parse_credentials(cmpt),
        applianceId: 3,
        flavourId: 5,
        userData: "I love unicorns.",
        architecture: "x64",
        state: cmpt.state
      }
    end
  end

  def all_test_method(site_id, cert)
   occi_client(endpoint(site_id), cert)
   computes = @client.describe (Occi::Infrastructure::Compute.new.kind.type_identifier)
  end

  private

  def parse_credentials(cmpt)
  # TODO update for multiple ssh keys version
    sshKey = parse_ssh_key(cmpt)
    if sshKey
      [
        {
          type: "sshKey",
          value: sshKey
        }
      ]
    else
      nil
    end
  end

  def parse_ssh_key(cmpt)
    #TODO add cheks for attributes
    user_data = Base64.decode64(cmpt.attributes.org.openstack.compute.user_data)
    user_data.lines.each do |line|
      result = line.chomp.match(/(ssh-(rsa|dsa|ecdsa) .*$)/)
      return result[0] if result
    end
    nil
  end
end
