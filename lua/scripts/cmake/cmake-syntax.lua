local M = {}
M.ApplySyntax = function(win)
  vim.fn.matchadd("@constructor", "[0-9]",100, -1, {window = win})
  vim.fn.matchadd("@comment.error", "\\verror:.*", 100, -1, {window = win})
  vim.fn.matchadd("@comment.error", "error\\w", 100, -1, {window = win})
  vim.fn.matchadd("@comment.warning", "\\vwarning:.*", 100, -1, {window = win})
  vim.fn.matchadd("@comment.warning", "warning\\w", 100, -1, {window = win})
  vim.fn.matchadd("@comment.note", "\\vnote:.*", 100, -1, {window = win})
  vim.fn.matchadd("@keyword", "\\[.*\\]",100, -1, {window = win})
  vim.fn.matchadd("@constructor", "\\[-.*\\]",100, -1, {window = win})
  vim.fn.matchadd("@annotation", "\\[\\[.*\\]\\]",100, -1, {window = win})
  vim.fn.matchadd("String", '"[^"]*"',100, -1, {window = win})
  vim.fn.matchadd("String", "'[^']*'",100, -1, {window = win})
  vim.fn.matchadd("Directory", "\\zs[A-Z]:\\(.*\\)(\\d\\+,\\d\\+):",100, -1, {window = win})
  vim.fn.matchadd("@comment", "\\zs|.*$",100, -1, {window = win})
  vim.fn.matchadd("none", "\\zs\\^\\(.*\\)",100, -1, {window = win})
  vim.fn.matchadd("conceal", "\\zsIn file included from \\(.*\\)",100, -1, {window = win})
end
return M
