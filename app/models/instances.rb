class Instances < Base
  def list(service_id, cert)
   occi_client(endpoint(service_id), cert)
   parse_instances(@client.describe(Occi::Infrastructure::Compute.new.kind.type_identifier))
  end

  def show(service_id, cert, instance_id)
    occi_client(endpoint(service_id), cert)
    instance_url = validate(service_id, cert, instance_id)
    if instance_url.blank?
      raise Errors::NotFoundError, "Instance '#{instance_id}' at site '#{service_id}' could not be found!"
    else
      parse_instances(@client.describe instance_url)
    end
  end


  protected

  def validate(service_id, cert, instance_id)
    instance_url = endpoint(service_id) + Base64.decode64(instance_id)
    if (@client.list Occi::Infrastructure::Compute.new.kind.type_identifier).include? instance_url
      instance_url
    else
      nil
    end
  end

  def parse_instances(computes)
    computes.collect do |cmpt|
      {
         id: Base64.strict_encode64(cmpt.location),
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


  # TODO remove when released
  def all_test_method(service_id, cert)
   occi_client(endpoint(service_id), cert)
   @client.describe (Occi::Infrastructure::Compute.new.kind.type_identifier)
  end

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
    ssh_key = parse_ssh_key(compute)
    [{ type: "sshKey", value: ssh_key }] if ssh_key
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
    Base64.decode64(compute.attributes.org.openstack.compute.user_data)
  end
end
