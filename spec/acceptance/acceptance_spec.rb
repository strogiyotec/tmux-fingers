require 'spec_helper'
require_relative '../tmuxomatic_setup.rb'

describe 'acceptance' do
  include_context "tmuxomatic setup"

  context "basic yank" do
    before do
      exec('cat test/fixtures/grep-output')
      invoke_fingers
      send_keys("b")
      echo_yanked
    end

    it { should contain_content("yanked text is scripts/debug.sh") }
  end

  context "custom patterns" do
    let(:config_name) { 'custom-patterns' }

    before do
      exec('cat test/fixtures/custom-patterns')

      send_keys("echo yanked text is ")

      invoke_fingers
      send_keys("y")
      paste

      invoke_fingers
      send_keys("b")
      paste

      send_keys("Enter")
    end

    it { should contain_content("yanked text is W00TW00TW00TYOLOYOLOYOLO") }
  end

  context "more than one match per line" do
    before do
      exec('cat test/fixtures/ip-output')

      invoke_fingers
      send_keys("i")
      echo_yanked
    end

    it { should contain_content("yanked text is 10.0.3.255") }
  end

  context "preserve zoom state" do
    before do
      send_prefix_and('%')
      send_prefix_and('%')
      send_prefix_and('%')
      send_prefix_and('z')

      exec('cat test/fixtures/grep-output')

      invoke_fingers
      send_keys("C-c")
      `tmux -L tmuxomatic wait-for -U tmuxomatic`
      exec('echo current pane is $(tmux list-panes -F "#{?window_zoomed_flag,zoomed,not_zoomed}" | head -1)')
    end

    it { should contain_content("current pane is zoomed") }
  end

  context "alt action" do
    let(:config_name) { 'alt-action' }

    before do
      `rm -rf /tmp/fingers-stub-output`
      exec('cat test/fixtures/grep-output')

      invoke_fingers
      send_keys("M-y")

      exec('cat /tmp/fingers-stub-output')

      sleep 10
    end

    it { should contain_content("action-stub => scripts/hints.sh") }

    after do
      `rm -rf /tmp/fingers-stub-output`
    end
  end

  context "shift action" do
    before do
      exec('cat test/fixtures/grep-output')

      send_keys('yanked text is ')
      invoke_fingers
      send_keys('Y')
    end

    it { should contain_content("yanked text is scripts/hints.sh") };
  end

  context "ctrl action" do
    let(:config_name) { 'ctrl-action' }
    let(:prefix) { 'C-b' }
    let(:hint_to_press) { 'C-y' }

    before do
      `rm -rf /tmp/fingers-stub-output`
      exec('cat test/fixtures/grep-output')

      invoke_fingers
      send_keys(hint_to_press)

      exec('cat /tmp/fingers-stub-output')
    end

    it { should contain_content("action-stub => scripts/hints.sh") }

    context "and is sending prefix" do
      let(:hint_to_press) { prefix }

      it { should contain_content("action-stub => scripts/debug.sh") }
    end

    after do
      `rm -rf /tmp/fingers-stub-output`
    end
  end

  context "copy stuff with quotes" do
    let(:config_name) { 'quotes' }

    before do
      sleep 3
      exec('cat test/fixtures/quotes')
      send_keys("echo yanked text is ")
      invoke_fingers
      send_keys("b")
      paste
      send_keys(" ")
      invoke_fingers
      send_keys("y")
      paste
    end

    it { should contain_content(%{yanked text is "laser" 'laser'}) }
  end

  # TODO multi match spec
end
