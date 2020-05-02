class Hinter
  def initialize(input:)
    @input = input
    @hints_by_text = {}
  end

  def run
    lines[0..-2].each { |line| process_line(line, "\n") }
    process_line(lines[-1], "")

    STDOUT.flush
    #write_hint_lookup!
  end

  private

  attr_reader :hints, :hints_by_text, :input

  def process_line(line, ending)
    print line.gsub(pattern) { |m| replace($~) } + ending
  end

  def write_hint_lookup!
    fd = File.open(3)

    hints_by_text.each do |text, hint|
      fd.write("#{hint}:#{text}\n")
    end

    fd.close()
  end

  def pattern
    @pattern ||= begin
      fingers_patterns = ENV['FINGERS_PATTERNS']
      #fingers_patterns = "[0-9]+"
      Regexp.new("(#{fingers_patterns})")
    end
  end

  def hints
    return @hints if @hints

    # TODO error handling o ke ase
    hints_path = File.join("/home/morantron/hacking/tmux-fingers/alphabets/qwerty/", n_matches.to_s)
    @hints = File.open(hints_path).read.split(" ").reverse
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

    output_hint = hint_format % hint
    output_text = highlight_format % text[hint.length..-1]

    return output_hint + output_text
  end

  def lines
    @lines ||= input.split("\n")
  end

  def highlight_format
    ENV['FINGERS_HIGHLIGHT_FORMAT']
  end

  def hint_format
    ENV['FINGERS_HINT_FORMAT']
  end

  def n_matches
    return @n_matches if @n_matches

    count = 0

    lines.each { |line| count = count + line.scan(pattern).length }

    @n_matches = count

    return count
  end
end
