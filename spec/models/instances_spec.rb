require 'spec_helper'

describe Instances do
  subject(:instances_instance) { described_class.new(cache: cache_double, db_collection: db_collection) }
  let(:db_collection) { 'appdb-test' }
  let(:cache_double) { instance_double('Utils::MongodbCache') }
  let(:cache_data) do
    file = File.read('spec/stub_data/appdb_stub.json')
    JSON.parse(file)
  end
  let(:appliance_id) { '511a2916-d480-4b56-b788-c76cb8c57509' }
  let(:site_id) { '247G0:4450G0' }
  let(:flavour_id) { 'cmVzb3VyY2VfdHBsIzE=' }
  before { allow(cache_double).to receive(:cache_fetch).with(db_collection) }

  # describe '#list' do
  #   context 'Fill in shizzeres' do
  #     before do
  #       allow(cache_double).to receive(:cache_read).with(db_collection).and_return(cache_data)
  #     end
  #     it('raises error for missing all') do
  #       expect { instances_instance.list('missing', 'spec/stub_data/x509up_u1000') }.to \
  #         raise_error(Errors::NotFoundError)
  #     end
  #
  #     it(' all') do
  #       VCR.use_cassette('model/client_instances') do
  #         expect { (instances_instance.list(site_id, '/tmp/x509up_u1000') }.to \
  #           eq 1 # raise_error(Errors::NotFoundError)
  #       end
  #     end
  #   end
  # end
end
