require 'rspec'
require 'csv'
require_relative '../api'

RSpec.describe 'Exchange Rates API' do
  let(:api_key) { '7f1c02ba86ddf4255822bad3' }
  let(:base_currency) { 'USD' }
  let(:mock_response) do
    {
      'result' => 'success',
      'conversion_rates' => {
        'EUR' => 0.935,
        'GBP' => 0.782,
        'JPY' => 147.5,
        'UAH' => 37.1,
        'CAD' => 1.25
      }
    }
  end

  before do
    # Заміна реального HTTP-запиту на підроблений
    allow(Net::HTTP).to receive(:get).and_return(mock_response.to_json)
  end

  describe '#fetch_exchange_rates' do
    it 'повертає успішну відповідь з правильними даними' do
      response = fetch_exchange_rates(base_currency)
      expect(response).to be_a(Hash)
      expect(response['result']).to eq('success')
      expect(response['conversion_rates']).to include('EUR', 'GBP', 'JPY', 'UAH', 'CAD')
    end

    it 'генерує помилку при некоректній відповіді' do
      allow(Net::HTTP).to receive(:get).and_return('<html>Not JSON</html>')
      expect { fetch_exchange_rates(base_currency) }.to raise_error(SystemExit)
    end
  end

  describe '#save_to_csv' do
    let(:filename) { 'test_exchange_rates.csv' }

    after do
      File.delete(filename) if File.exist?(filename)
    end

    it 'створює файл CSV із правильними даними' do
      rates = mock_response['conversion_rates']
      save_to_csv(rates, filename)

      expect(File.exist?(filename)).to eq(true)

      csv_data = CSV.read(filename, headers: true)
      expect(csv_data.headers).to eq(['Валюта', 'Курс'])
      expect(csv_data.map { |row| row['Валюта'] }).to include('EUR', 'GBP', 'JPY', 'UAH', 'CAD')
      expect(csv_data.find { |row| row['Валюта'] == 'EUR' }['Курс']).to eq('0.935')
    end
  end
end
