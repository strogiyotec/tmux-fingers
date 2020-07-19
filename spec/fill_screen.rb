require 'securerandom'

ENV['LINES'].to_i.times do
  codes = []
  (ENV['COLUMNS'].to_i / 16 - 1).times do
    codes << SecureRandom.hex(8).to_s
  end

  puts codes.join(' ')
end
