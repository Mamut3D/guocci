describe Appliances do

  context '#method_missing' do

    it 'raises a NameError' do
      expect { Appliances.new.does_not_exist }.to raise_error(NameError)
    end

    it 'raises an error with a message containing the word undefined' do
      begin
        Appliances.new.does_not_exist
        expect(true).to be false
      rescue NameError => err
        expect(err.message).to include('undefined')
      end
    end

  end

end
