require 'spec_helper'

describe Flavours do
  subject(:flavours_instance) { described_class.new(cache: cache_double, db_collection: db_collection) }
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

  describe '#list' do
    context 'db contains data' do
      before { allow(cache_double).to receive(:cache_read).with(db_collection).and_return(cache_data) }
      it('raises error for missing all') do
        expect { flavours_instance.list('missing', 'missing') }.to \
          raise_error(Errors::NotFoundError)
      end
      it('raises error for missing site') do
        expect { flavours_instance.list(appliance_id, 'missing') }.to \
          raise_error(Errors::NotFoundError)
      end
      it('returns flavours') { expect(flavours_instance.list(appliance_id, site_id).count).to eq 5 }
    end
  end

  describe '#show' do
    context 'db contains data' do
      before { allow(cache_double).to receive(:cache_read).with(db_collection).and_return(cache_data) }
      it('raises error for missing all') do
        expect { flavours_instance.show('missing', 'missing', 'missing') }.to \
          raise_error(Errors::NotFoundError)
      end
      it('raises error for missing site') do
        expect { flavours_instance.show(appliance_id, 'missing', 'missing') }.to \
          raise_error(Errors::NotFoundError)
      end
      it('raises error for missing flavour') do
        expect { flavours_instance.show(appliance_id, site_id, 'missing') }.to \
          raise_error(Errors::NotFoundError)
      end
      it('returns flavours') { expect(flavours_instance.show(appliance_id, site_id, flavour_id).count).to eq 5 }
    end
  end
end
