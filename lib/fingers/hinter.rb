class ::Fingers::Hinter
  def initialize(input:, width:, state:)
    @input = input
    @width = width
    @hints_by_text = {}
    @state = state
  end

  def run
    prepend_new_lines

    lines[0..-2].each { |line| process_line(line, "\n") }
    process_line(lines[-1], "")

    STDOUT.flush

    build_lookup_table!
  end

  def lookup(hint)
    lookup_table[hint]
  end

  private

  attr_reader :hints, :hints_by_text, :input, :lookup_table, :width, :state

  def prepend_new_lines
    wrapped_lines_count.times { print "\n" }
  end

  def wrapped_lines_count
    @wrapped_lines_count ||= (lines.sum { |line| [((line.length.to_f - 1.0) / width.to_f).floor, 0].max})
  end

  def build_lookup_table!
    @lookup_table = hints_by_text.invert
  end

  def process_line(line, ending)
    output = line.gsub(pattern) { |m| replace($~) }

    print(output + ending)
  end

  def pattern
    @pattern ||= Regexp.compile("(#{Fingers.config.patterns.join("|")})")
  end

  def hints
    return @hints if @hints

    @hints = Huffman.new(alphabet: Fingers.config.alphabet, n: n_matches).generate_hints
  end

  def replace(match)
    text = match[0]

    return text if hints.empty?

    captured_text = match && match.named_captures["capture"] || text

    if hints_by_text.has_key?(captured_text)
      hint = hints_by_text[captured_text]
    else
      hint = hints.pop
      hints_by_text[captured_text] = hint
    end

    output_hint = hint_format_for(hint, text) % hint
    # TODO this should be output hint without ansi escape sequences
    # ANSI_ESCAPE_SEQUENCE_PATTERN = /\033\[([0-9]+);([0-9]+);([0-9]+)m(.+?)\033\[0m|([^\033]+)/
    output_text = highlight_format_for(hint, text) % text[hint.length..-1]

    return output_hint + output_text
  end

  def lines
    @lines ||= input.split("\n")
  end

  def highlight_format_for(hint, text)
    if state.selected_hints.include?(hint)
      Fingers.config.selected_highlight_format
    else
      Fingers.config.highlight_format
    end
  end

  def hint_format_for(hint, text)
    if state.selected_hints.include?(hint)
      Fingers.config.selected_hint_format
    else
      Fingers.config.hint_format
    end
  end

  def n_matches
    return @n_matches if @n_matches

    count = 0

    lines.each { |line| count = count + line.scan(pattern).length }

    # TODO are we taking into account duplicates here?
    @n_matches = count

    return count
  end
end
