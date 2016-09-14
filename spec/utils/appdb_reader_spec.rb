# Appdbreader util test
# checks output format of appdb data
# uses prerecorded http responses with vcr gem
describe Utils::AppdbReader do
  let(:service_id) { '247G0:4450G0' }
  let(:appliance_id) { '299cfae2-1749-43b1-8c4c-9bd62bbad44b' }
  let(:flavour_id) { 'cmVzb3VyY2VfdHBsIzQ=' }

  describe '#appdb_raw_request' do
    it('response from appdb is succesfull') do
      VCR.use_cassette('model/appdb_response') { expect(Utils::AppdbReader.appdb_raw_request.success?).to eq true }
    end
  end

  describe '#all' do
    it('response from appdb contains 16 services') do
      VCR.use_cassette('model/appdb_response') { expect(Utils::AppdbReader.all.count).to eq 16 }
      end

    it('response from appdb contains 8 items at first service') do
      VCR.use_cassette('model/appdb_response') { expect(Utils::AppdbReader.all.first.count).to eq 8 }
    end

    it('response from appdb contains 21 appliances at first service') do
      VCR.use_cassette('model/appdb_response') { expect(Utils::AppdbReader.all.first[:appliances].count).to eq 21 }
    end

    it('response from appdb contains 5 flavours at first service') do
      VCR.use_cassette('model/appdb_response') { expect(Utils::AppdbReader.all.first[:flavours].count).to eq 5 }
    end

    it('response from appdb contains specific service') do
      VCR.use_cassette('model/appdb_response') do
        expect(Utils::AppdbReader.all.any? { |srv| srv[:id] == service_id }).to eq true
      end
    end

    it('response from appdb contains specific appliance at first service') do
      VCR.use_cassette('model/appdb_response') do
        expect(Utils::AppdbReader.all.first[:appliances].any? { |appl| appl[:id] == appliance_id} ).to eq true
      end
    end

    it('response from appdb contains specific flavour at first service') do
      VCR.use_cassette('model/appdb_response') do
        expect(Utils::AppdbReader.all.first[:flavours].any? { |flv| flv[:id] == flavour_id }).to eq true
      end
    end
  end
end
