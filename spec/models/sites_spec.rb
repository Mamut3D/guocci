require 'spec_helper'

describe Sites do
  subject(:sites_instance) { described_class.new(cache: cache_double, db_collection: db_collection) }
  let(:db_collection) { 'appdb-test' }
  let(:cache_double) { instance_double('Utils::MongodbCache') }
  let(:cache_data) do
    file = File.read('spec/stub_data/appdb_stub.json')
    JSON.parse(file)
  end
  let(:appliance_id) { '511a2916-d480-4b56-b788-c76cb8c57509' }
  let(:site_id) { '247G0:4450G0' }
  before { allow(cache_double).to receive(:cache_fetch).with(db_collection) }

  describe '#list' do
    context 'db empty' do
      before { allow(cache_double).to receive(:cache_read).with(db_collection).and_return([]) }
      it('returns empty array') { expect(sites_instance.list(nil)).to be_empty }
    end

    context 'db contains data' do
      before { allow(cache_double).to receive(:cache_read).with(db_collection).and_return(cache_data) }
      it('returns site list') { expect(sites_instance.list(nil).count).to eq 2 }
      it('raises error for missing appliance') do
        expect { sites_instance.list('missing') }.to \
          raise_error(Errors::NotFoundError)
      end
      it('returns sites for selected appliance') { expect(sites_instance.list(appliance_id).count).to eq 1 }
    end
  end

  describe '#show' do
    context 'db empty' do
      before { allow(cache_double).to receive(:cache_read).with(db_collection).and_return([]) }
      it('raises error for missing appliance') do
        expect { sites_instance.show('missing', 'missing') }.to \
          raise_error(Errors::NotFoundError)
      end
    end

    context 'db contains data' do
      before { allow(cache_double).to receive(:cache_read).with(db_collection).and_return(cache_data) }
      it('raises error for missing appliance') do
        expect { sites_instance.show('missing', 'missing') }.to \
          raise_error(Errors::NotFoundError)
      end
      it('raises error for missing site') do
        expect { sites_instance.show(appliance_id, 'missing') }.to \
          raise_error(Errors::NotFoundError)
      end
      it('returns selected site') { expect(sites_instance.show(appliance_id, site_id).count).to eq 4 }
    end
  end
end
