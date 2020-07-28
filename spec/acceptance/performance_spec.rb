require 'spec_helper'
require_relative '../tmuxomatic_setup.rb'

describe 'performance' do
  include_context 'tmuxomatic setup'

  it 'runs smooooooth' do
    100.times do
      exec('COLUMNS=$COLUMNS LINES=$LINES ruby spec/fill_screen.rb')
      sleep 1
      invoke_fingers
      sleep 1
      send_keys('q')
      sleep 1
    end
  end
end
