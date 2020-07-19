class ::Fingers::MatchFormatter
  class << self
    def for(compact:)
      new(
        hint_format: hint_format(selected: false, compact: compact),
        highlight_format: highlight_format(selected: false, compact: compact),
        selected_hint_format: hint_format(selected: true, compact: compact),
        selected_highlight_format: highlight_format(selected: true, compact: compact),
        hint_position: Fingers.config.hint_position,
        compact: Fingers.config.compact_hints,
      )
    end

    private

    def hint_format(selected:, compact:)
      Fingers.config.send(format_method('hint', selected, compact))
    end

    def highlight_format(selected:, compact:)
      Fingers.config.send(format_method('highlight', selected, compact))
    end

    def maybe(string, should_be_included)
      should_be_included ? string : nil
    end

    def format_method(part, selected, compact)
      [
        maybe("selected", selected),
        "#{part}_format",
        maybe("nocompact", !compact)
      ].compact.join("_")
    end
  end

  def initialize(hint_format:, highlight_format:, selected_hint_format:, selected_highlight_format:, hint_position:, compact:)
    @hint_format = hint_format
    @highlight_format = highlight_format
    @selected_hint_format = selected_hint_format
    @selected_highlight_format = selected_highlight_format
    @hint_position = hint_position
    @compact = compact
  end

  def format(hint:, highlight:, selected:)
    format_string(selected) % input(hint, highlight)
  end

  private

  attr_reader :hint_format, :highlight_format, :selected_hint_format, :selected_highlight_format, :hint_position, :compact

  def format_string(selected)
    @format_string ||= begin
      result = selected_or_default_format(selected)
      result.reverse! if hint_position == 'right'
      result.join
    end
  end

  def selected_or_default_format(selected)
    if selected
      [selected_hint_format, selected_highlight_format]
    else
      [hint_format, highlight_format]
    end
  end

  def input(hint, highlight)
    processed_highlight = process_highlight(hint, highlight)

    if hint_position == 'right'
      [processed_highlight, hint]
    else
      [hint, processed_highlight]
    end
  end

  def process_highlight(hint, highlight)
    return highlight unless compact

    if hint_position == 'right'
      highlight[0..-(hint.length + 1)]
    else
      highlight[hint.length..-1]
    end
  end
end
