require 'neovim'

Neovim.plugin do |plug|
  plug.command(:RescueSend, range: true) do |nvim, range_start, range_end|
    # 選択範囲の取得（複数行）
    selected_lines = nvim.get_current_buf.lines[(range_start - 1)..(range_end - 1)]

    # インデントの取得（選択範囲の最初の行から）
    first_selected_line = nvim.get_current_buf.lines[range_start - 1]
    base_indent = first_selected_line.match(/^\s*/)[0] # 最初の行のインデント
    deeper_indent = base_indent + '  '

    # rescueブロックの生成
    rescue_block = [
      "#{base_indent}begin",
      *selected_lines.map { |line| "#{deeper_indent}#{line.strip}" }, # 各行を正しいインデントで整形
      "#{base_indent}rescue StandardError => e",
      "#{deeper_indent}Rails.logger.error(e)",
      "#{deeper_indent}raise e",
      "#{base_indent}end"
    ]

    # 選択範囲を削除して新しいコードを挿入
    buf = nvim.get_current_buf
    buf.set_lines(range_start - 1, range_end, true, []) # 選択範囲を削除
    buf.set_lines(range_start - 1, range_start - 1, true, rescue_block) # rescueブロックを挿入
  end
end
