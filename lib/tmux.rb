class Tmux
  include Singleton

  def refresh!
    @panes = nil
    @windows = nil
  end

  def panes
    return @panes if @panes

    format = build_json_format(%w[
        pane_id
        window_id
        pane_width
        pane_height
        scroll_position
        pane_in_mode
        window_zoomed_flag
     ])

    @panes = as_json_collection(`#{tmux} list-panes -a -F '#{format}'`)
  end

  def windows
    return @windows if @windows

    format = build_json_format(%w[
      window_id
      window_width
      window_height
    ])

    @windows = as_json_collection(`#{tmux} list-windows -a -F '#{format}'`)
  end

  def new_session(name, cmd, width, height)
    flags = []

    flags.push('-f', config_file) if config_file

    `#{tmux} #{flags.join(' ')} new-session -d -s #{name} -x #{width} -y #{height} '#{cmd}'`
  end

  def start_server
    flags = []

    flags.push('-f', config_file) if config_file

    `#{tmux} #{flags.join(' ')} start-server`
  end


  def pane_by_id(id)
    panes.find { |pane| pane["pane_id"] == id }
  end

  def window_by_id(id)
    windows.find { |window| window["window_id"] == id }
  end

  def pane_exec(pane_id, cmd)
    send_keys(pane_id, " #{cmd}")
    send_keys(pane_id, "Enter")
  end

  def send_keys(pane_id, keys)
    `#{tmux} send-keys -t '#{pane_id}' '#{keys}'`
  end

  def capture_pane(pane_id)
    pane = pane_by_id(pane_id)


    if pane["pane_in_mode"] == '1'
      start_line = -pane["scroll_position"].to_i
      end_line = pane["pane_height"].to_i - pane["scroll_position"].to_i - 1

      `#{tmux} capture-pane -J -p -t '#{pane_id}' -S #{start_line} -E #{end_line}`
    else
      `#{tmux} capture-pane -J -p -t '#{pane_id}'`
    end

  end

  def create_window(name, cmd, pane_width, pane_height)
    format = build_json_format(%w[window_id pane_id])

    output = JSON.parse(
      `#{tmux} new-window -P -d -n "#{name}" -F '#{format}' "#{cmd}"`
    )

    return [output["window_id"], output["pane_id"]]
  end

  def swap_panes(src_id, dst_id)
    `#{tmux} swap-pane -d -Z -s '#{src_id}' -t '#{dst_id}'`
  end

  # TODO this command is version dependant D:
  def resize_window(window_id, width, height)
    `#{tmux} resize-window -t "#{window_id}" -x #{width} -y #{height}`
  end

  # TODO this command is version dependant D:
  def resize_pane(window_id, width, height)
    `#{tmux} resize-pane -t "#{window_id}" -x #{width} -y #{height}"`
  end

  def last_pane_id
    `#{tmux} display -pt':.{last}' '#{pane_id}'`
  end

  def set_window_option(name, value)
    `#{tmux} set-window-option #{name} #{value}`
  end

  def set_key_table(table)
    `#{tmux} set-window-option key-table #{table}`
    `#{tmux} switch-client -T #{table}`
  end

  def disable_prefix
    set_global_option('prefix', 'None')
    set_global_option('prefix2', 'None')
  end

  def set_global_option(name, value)
    `#{tmux} set-option -g #{name} #{value}`
  end

  def get_global_option(name)
    `#{tmux} show -gqv #{name}`.chomp
  end

  def set_buffer(value)
    return unless value
    `#{tmux} set-buffer "#{value.shellescape}"`
  end

  def select_pane(id)
    `#{tmux} select-pane -t #{id}`
  end

  def zoom_pane(id)
    `#{tmux} resize-pane -Z -t #{id}`
  end

  def parse_format(format)

    `#{File.dirname(__FILE__)}/../vendor/tmux-printer/tmux-printer '#{format}'`.chomp
  end

  attr_accessor :socket, :config_file

  private

  def tmux
    flags = []

    flags.push('-L', socket) if socket

    return "tmux #{flags.join(' ')}" unless flags.empty?
    "tmux"
  end

  def build_json_format(fields)
    "{#{fields.map { |field| '"%s": "#{%s}"' % [field, field] }.join(", ")}}"
  end

  def as_json_collection(output)
    lines = output.gsub(/\n$/, '').split("\n")
    JSON.parse("[#{lines.join(",")}]")
  end
end
