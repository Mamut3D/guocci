class Instances < Base
  def list(service_id, cert)
    occi_client(endpoint(service_id), cert)
    parse_instances(@client.describe(Occi::Infrastructure::Compute.new.kind.type_identifier))
  end

  def show(service_id, cert, instance_id)
    occi_client(endpoint(service_id), cert)
    instance_url = validate(service_id, cert, instance_id)
    parse_instances(@client.describe(instance_url))
  end

  def destroy(service_id, cert, instance_id)
    occi_client(endpoint(service_id), cert)
    instance_url = validate(service_id, cert, instance_id)
    @client.delete instance_url
  end

  def create(service_id, cert, instance_id)
    # occi_client(endpoint(service_id), cert)
    # instance_url = validate(service_id, cert, instance_id)
    # @client.delete instance_url
  end

  protected

  def validate(service_id, _cert, instance_id)
    instance_url = endpoint(service_id) + Base64.decode64(instance_id)
    return instance_url if (@client.list Occi::Infrastructure::Compute.new.kind.type_identifier).include? instance_url
    raise Errors::NotFoundError, "Instance '#{instance_id}' at site '#{service_id}' could not be found!"
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

  def appliance_id(compute)
    appliance = appliance_mixin(compute)
    appliance.term if appliance.present?
  end

  def appliance_mixin(compute)
    model = @client.model
    compute.mixins.find do |mixin|
      # Awfull workaround due to bug in occi core, should be fixed in new occi client with
      # mixin.related_to? (Occi::Infrastructure::OsTpl.mixin.type_identifier)
      model.get_by_id(mixin.type_identifier).present? && \
        model.get_by_id(mixin.type_identifier).related_to?(Occi::Infrastructure::OsTpl.mixin.type_identifier)
    end
  end

  def flavour_mixin(compute)
    compute.mixins.find { |mixin| mixin.scheme == 'http://fedcloud.egi.eu/occi/compute/flavour/1.0#' }
  end

  def user_data_mixin(compute)
    compute.mixins.find { |mixin| mixin.type_identifier == 'http://schemas.openstack.org/compute/instance#user_data' }
  end

  def parse_credentials(compute)
    # TODO: update for multiple ssh keys version
    ssh_key = parse_ssh_key(compute)
    [{ type: 'sshKey', value: ssh_key }] if ssh_key
  end

  def parse_ssh_key(compute)
    # TODO: add cheks for attributes
    parsed_user_data = parse_user_data(compute)
    return if parsed_user_data.blank?
    parsed_user_data.lines.each do |line|
      result = line.chomp.match(/(ssh-(rsa|dsa|ecdsa) .*$)/)
      return result[0] if result
    end
  end

  def parse_user_data(compute)
    Base64.decode64(compute.attributes.org.openstack.compute.user_data) if user_data_mixin(compute)
  end
end
