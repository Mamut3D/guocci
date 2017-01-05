class Instances < Base
  def list
    parse_instances(@client.describe(Occi::Infrastructure::Compute.new.kind.type_identifier))
  end

  def show(instance_id)
    instance_url = validate(@service_id, instance_id)
    parse_instances(@client.describe(instance_url))
  end

  def destroy(instance_id)
    instance_url = validate(@service_id, instance_id)
    @client.delete instance_url
  end

  def create(instance)
    return nil unless valide_input(instance)
    create_compute(instance)
  end

  protected

  def valide_input(instance)
    # TODO: find some json validator and validate input
    instance
  end

  def create_compute(instance)
    compute = @client.get_resource(Occi::Infrastructure::Compute.new.kind.type_identifier)
    compute.mixins << @client.get_mixin(instance[:applianceId], 'os_tpl') \
                   << @client.get_mixin(instance[:flavourId], 'resource_tpl') \
                   << context_mixin
    compute.title = compute.hostname = instance[:name]
    # TODO: add credentials validation
    compute.attributes['org.openstack.credentials.publickey.name'] = 'Public SSH key'
    compute.attributes['org.openstack.credentials.publickey.data'] = instance[:credentials][0]['value'].strip
    @client.create compute
  end

  def context_mixin
    mxn_attrs = Occi::Core::Attributes.new
    mxn_attrs['org.openstack.credentials.publickey.name'] = {}
    mxn_attrs['org.openstack.credentials.publickey.data'] = {}
    Occi::Core::Mixin.new(
      'http://schemas.openstack.org/instance/credentials#',
      'public_key',
      'OS contextualization mixin',
      mxn_attrs
    )
  end

  def validate(service_id, instance_id)
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
        flavourId: flavour_id(cmpt),
        userData: parse_user_data(cmpt),
        architecture: cmpt.architecture,
        state: cmpt.state
      }
    end
  end

  def appliance_id(compute)
    appliance = appliance_mixin(compute)
    appliance.term if appliance
  end

  def flavour_id(compute)
    flavour = flavour_mixin(compute)
    flavour.term if flavour
  end

  def appliance_mixin(compute)
    compute.mixins.find do |mixin|
      # Awfull workaround due to bug in occi core, should be fixed in new occi client with
      @client.model.get_by_id(mixin.type_identifier).present? && \
        @client.model.get_by_id(mixin.type_identifier).related_to?(Occi::Infrastructure::OsTpl.mixin.type_identifier)
    end
  end

  def flavour_mixin(compute)
    compute.mixins.find do |mixin|
      # Awfull workaround due to bug in occi core, should be fixed in new occi client with
      @client.model.get_by_id(mixin.type_identifier).present? && \
        @client.model.get_by_id(mixin.type_identifier).related_to?(Occi::Infrastructure::ResourceTpl.mixin.type_identifier)
    end
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
    nil
  end

  def parse_user_data(compute)
    Base64.decode64(compute.attributes.org.openstack.compute.user_data) if user_data_mixin(compute)
  end
end
