RSpec.describe Appliances do
  subject(:appliances_instance) { described_class.new(cache: cache_double, db_collection: db_collection) }
  let(:db_collection) { 'appdb-test' }
  let(:cache_double) { instance_double('Utils::MongodbCache') }
  let(:cache_data) do
    file = File.read('spec/stub_data/appdb_stub.json')
    JSON.parse(file)
  end
  let(:appliance_id) { 'fd092fa5-cd43-401d-959f-6ab380191d71' }

  before { allow(cache_double).to receive(:cache_fetch).with(db_collection) }

  describe '#list' do
    context 'appliaces empty' do
      before { allow(cache_double).to receive(:cache_read).with(db_collection).and_return([]) }
      it('returns empty appliance list') { expect(appliances_instance.list).to be_empty }
    end

    context 'db contains data' do
      before { allow(cache_double).to receive(:cache_read).with(db_collection).and_return(cache_data) }
      it('returns appliance list') { expect(appliances_instance.list.count).to eq 11 }
    end
  end

  describe '#show' do
    before { allow(cache_double).to receive(:cache_read).with(db_collection).and_return(cache_data) }
    context 'db contains data' do
      it('returns appliance') { expect(appliances_instance.show(appliance_id).count).to eq 4 }
      it('raises NotFoundError when appliance id is missing') do
        expect { appliances_instance.show('missing').count }.to \
          raise_error(Errors::NotFoundError)
      end
    end
  end
end
