require 'json'
require 'singleton'

class Tmux
  include Singleton

  def panes
    format = build_json_format(%w[
        pane_id
        window_id
        pane_width
        pane_height
        scroll_position
        pane_in_mode
        window_zoomed_flag
     ])

    as_json_collection(`tmux list-panes -a -F '#{format}'`)
  end

  def windows
    format = build_json_format(%w[
      window_id
      window_width
      window_height
    ])
  end

  def pane_by_id(id)
    panes.find { |pane| pane["pane_id"] == id }
  end

  def window_by_id(id)
    windows.find { |window| window["window_id"] == id }
  end

  def pane_exec(pane_id, cmd)
    `tmux send-keys -t '#{pane_id}' ' #{cmd}'`
    `tmux send-keys -t '#{pane_id}' 'Enter'`
  end

  def capture_pane(pane_id)
    start_line = '0'
    end_line = '-'


    `tmux capture-pane -p -t '#{pane_id}' -S '#{start_line}' -E '#{end_line}' -J`
  end

  def create_window(name, cmd, pane_width, pane_height)
    format = build_json_format(%w[window_id pane_id])

    output = JSON.parse(
      `tmux new-window -P -d -n "#{name}" -F '#{format}' "#{cmd}"`
    )

    return [output["window_id"], output["pane_id"]]
  end

  def swap_panes(src_id, dst_id)
    `tmux swap-pane -s '#{src_id}' -t '#{dst_id}'`
  end

  # TODO this command is version dependant D:
  def resize_window(window_id, width, height)
    `tmux resize-window -t "#{window_id}" -x #{width} -y #{height}"`
  end

  def last_pane_id
    `tmux display -pt':.{last}' '#{pane_id}'`
  end

  private

  def build_json_format(fields)
    "{#{fields.map { |field| '"%s": "#{%s}"' % [field, field] }.join(", ")}}"
  end

  def as_json_collection(output)
    lines = output.gsub(/\n$/, '').split("\n")
    JSON.parse("[#{lines.join(",")}]")
  end
end
