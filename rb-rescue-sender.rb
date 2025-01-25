require 'neovim'

Neovim.plugin do |plug|
  plug.command(:RescueSend, range: true) do |nvim, range_start, range_end|
    selected_lines = nvim.get_current_buf.lines[(range_start - 1)..(range_end - 1)]

    first_selected_line = nvim.get_current_buf.lines[range_start - 1]
    base_indent = first_selected_line.match(/^\s*/)[0]
    deeper_indent = base_indent + '  '

    rescue_block = [
      "#{base_indent}begin",
      *selected_lines.map { |line| "#{deeper_indent}#{line.strip}" }, 
      "#{base_indent}rescue StandardError => e",
      "#{deeper_indent}Rails.logger.error(e)",
      "#{deeper_indent}raise e",
      "#{base_indent}end"
    ]

    buf = nvim.get_current_buf
    buf.set_lines(range_start - 1, range_end, true, [])
    buf.set_lines(range_start - 1, range_start - 1, true, rescue_block)
  end
end
