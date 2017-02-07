class Interfaces < Base
  def list(instance_id)
    # Base64.decode64(instance_id)
    @client.describe(Base64.decode64(instance_id)).collect do |resource|
      resource.links.collect do |link|
        format(link) if link.kind.type_identifier == Occi::Infrastructure::Networkinterface.type_identifier
      end.compact
    end.flatten
  end

  def show(instance_id, interface_id)
  end

  def destroy(instance_id, interface_id)
  end

  def create(instance_id)
  end

  private

  def format(link)
    {
      id: link.id,
      networkId: Base64.strict_encode64(link.target),
      #  address: link.attributes.occi.networkinterface.address,#{}"125.45.78.12",
      #  gateway: link.gateway,
      mac: link.attributes.occi.networkinterface.mac,
      state: link.attributes.occi.networkinterface.state,
      allocation: 'dynamic',
      kind: link.attributes
    }
  end
end
