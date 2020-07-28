require 'rspec/expectations'

shared_context 'tmuxomatic setup', a: :b do
  let(:tmuxomatic) do
    Tmux.instance.socket = 'tmuxomatic'
    Tmux.instance.config_file = '/dev/null'

    # TODO: resize window to 80x24?

    Tmux.instance
  end

  let(:config_name) { 'basic' }
  let(:prefix) { 'C-a' }
  let(:fingers_key) { 'F' }

  let(:tmuxomatic_pane_id) { tmuxomatic.panes.first['pane_id'] }
  let(:tmuxomatic_window_id) { tmuxomatic.panes.first['window_id'] }

  def send_keys(keys)
    fork do
      tmuxomatic.send_keys(tmuxomatic_pane_id, keys)
    end
    # TODO: key is received, is it even possible?
    sleep 0.2
  end

  def exec(cmd, with_lock: true)
    `tmux -L tmuxomatic wait-for -L tmuxomatic` if with_lock
    tmuxomatic.pane_exec(tmuxomatic_pane_id, cmd)
  end

  def capture_pane
    tmuxomatic.capture_pane(tmuxomatic_pane_id)
  end

  def invoke_fingers
    send_keys(prefix)
    send_keys(fingers_key)
    # TODO: detect when fingers is ready
    sleep 0.5
  end

  def echo_yanked
    exec('clear')
    send_keys('echo yanked text is ')
    paste
  end

  def paste
    send_keys(prefix)
    send_keys(']')
    sleep 0.5
  end

  def send_prefix_and(keys)
    send_keys(prefix)
    send_keys(keys)
  end

  def tmuxomatic_unlock_path
    File.expand_path(File.join(File.dirname(__FILE__), '.tmuxomatic_unlock_command_prompt'))
  end

  def fingers_root
    File.expand_path(File.join(File.dirname(__FILE__), '../'))
  end

  def fingers_stubs_path
    File.expand_path(File.join(
                       fingers_root,
                       './test/stubs'
                     ))
  end

  def within_lock(lock)
    `tmux -L tmuxomatic wait-for -L #{lock} &>> /tmp/fingers.test.log`
    yield
    `tmux -L tmuxomatic wait-for -U #{lock} &>> /tmp/fingers.test.log`
  end

  before do
    conf_path = File.expand_path(
      File.join(
        File.dirname(__FILE__),
        '../test/conf/',
        "#{config_name}.conf"
      )
    )

    tmuxomatic
    tmuxomatic.new_session('tmuxomatic', "PATH=\"#{fingers_root}:#{fingers_stubs_path}:$PATH\" TMUX='' tmux -L tmuxomatic_inner -f #{conf_path}", 80, 24)
    tmuxomatic.set_global_option('prefix', 'None')
    tmuxomatic.set_global_option('status', 'off')
    tmuxomatic.resize_window(tmuxomatic_window_id, 80, 24)

    # TODO: find out how to wait until tmux is ready
    sleep 1.0

    exec("export PROMPT_COMMAND='#{tmuxomatic_unlock_path}'", with_lock: false)
    exec("export PS1='# '", with_lock: false)
    exec('clear', with_lock: false)
  end

  after do
    `tmux -L tmuxomatic kill-server`
    `tmux -L tmuxomatic_inner kill-server`
  end
end

RSpec::Matchers.define :contain_content do |expected|
  match do
    tmuxomatic.capture_pane(tmuxomatic_pane_id).include?(expected)
  end
end
