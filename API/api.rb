require 'net/http'
require 'json'
require 'csv'

# Конфігурація
API_KEY = '7f1c02ba86ddf4255822bad3'
BASE_URL = "https://v6.exchangerate-api.com/v6/#{API_KEY}/latest"
BASE_CURRENCY = 'USD'
OUTPUT_FILE = 'exchange_rates.csv'

# Метод для отримання курсів валют із API
def fetch_exchange_rates(base_currency)
  url = URI("#{BASE_URL}/#{base_currency}")
  response = Net::HTTP.get(url)

  begin
    JSON.parse(response)
  rescue JSON::ParserError
    puts "Помилка парсингу відповіді від API: #{response}"
    exit(1) # Завершення програми з кодом помилки
  end
end

def save_to_csv(data, filename)
  CSV.open(filename, 'w', write_headers: true, headers: ['Валюта', 'Курс']) do |csv|
    data.each do |currency, rate|
      csv << [currency, rate]
    end
  end
end

begin
  # Отримання даних з API
  response = fetch_exchange_rates(BASE_CURRENCY)

  if response['result'] == 'success'
    rates = response['conversion_rates']
    selected_currencies = %w[EUR GBP JPY UAH CAD]
    filtered_rates = rates.select { |currency, _| selected_currencies.include?(currency) }

    # Збереження у CSV
    save_to_csv(filtered_rates, OUTPUT_FILE)
    puts "Дані успішно збережено в файл: #{OUTPUT_FILE}"
  else
    puts "Помилка отримання даних: #{response['error-type']}"
  end
rescue StandardError => e
  puts "Сталася помилка: #{e.message}"
end
