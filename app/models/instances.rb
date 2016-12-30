class Instances < Base
  def list(service_id, cert)
   occi_client(endpoint(service_id), cert)
   computes = @client.describe (Occi::Infrastructure::Compute.new.kind.type_identifier)
   computes.collect do |cmpt|
     {
        id: cmpt.id,
        name: (cmpt.title || cmpt.hostname),
        credentials: parse_credentials(cmpt),
        applianceId: appliance_id(cmpt),
        flavourId: flavour_mixin(cmpt).to_s,
        userData: parse_user_data(cmpt),
        architecture: cmpt.architecture,
        state: cmpt.state
      }
    end
  end

  def show(service_id, cert, instance_id)
   instances = list(service_id, cert)
   instances.select! { |instance| instance[:id] == instance_id }
   if instances.blank?
     raise Errors::NotFoundError, "Instance '#{instance_id}' at site '#{service_id}' could not be found!"
   end
   instances.first
  end

  # TODO remove when released
  def all_test_method(service_id, cert)
   occi_client(endpoint(service_id), cert)
   computes = @client.describe (Occi::Infrastructure::Compute.new.kind.type_identifier)
  end

  private

  def appliance_id(compute)
    appliance = appliance_mixin(compute)
    appliance.term if appliance.present?
  end

  def appliance_mixin(compute)
    model = @client.model
    compute.mixins.find do |mixin|
      # Awfull workaround due to bug in occi core, should be fixed in new occi client with
      # mixin.related_to? (Occi::Infrastructure::OsTpl.mixin.type_identifier)
      model.get_by_id(mixin.type_identifier).present? and \
      model.get_by_id(mixin.type_identifier).related_to?(Occi::Infrastructure::OsTpl.mixin.type_identifier)
    end
  end

  def flavour_mixin(compute)
    model = @client.model
    compute.mixins.find do |mixin|
      # Awfull workaround due to bug in occi core, should be fixed in new occi client with
      # mixin.related_to? (Occi::Infrastructure::OsTpl.mixin.type_identifier)
      model.get_by_id(mixin.type_identifier).present? and \
      model.get_by_id(mixin.type_identifier).related_to?(Occi::Infrastructure::ResourceTpl.mixin.type_identifier)
    end
  end

  def parse_credentials(compute)
  # TODO update for multiple ssh keys version
    sshKey = parse_ssh_key(compute)
    [{ type: "sshKey", value: sshKey }] if sshKey
  end

  def parse_ssh_key(compute)
    #TODO add cheks for attributes
    parse_user_data(compute).lines.each do |line|
      result = line.chomp.match(/(ssh-(rsa|dsa|ecdsa) .*$)/)
      return result[0] if result
    end
    nil
  end

  def parse_user_data(compute)
    user_data = Base64.decode64(compute.attributes.org.openstack.compute.user_data)
  end
end
