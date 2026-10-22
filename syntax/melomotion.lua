-- Highlighting for the song sheet that :Melomotion show opens.
if vim.b.current_syntax then
  return
end

-- Later matches win where two start at the same place, so the title comes after the notes.
vim.cmd([[
  syntax match melomotionNote /[♪♫]/
  syntax match melomotionTitle /^♫ .*/
  syntax match melomotionDate /\%2l.\+/
  syntax match melomotionLabel /^\[.*\|^  [→⇄] .*/ contains=melomotionPart,melomotionJoin,melomotionCount
  syntax match melomotionPart /^\[\zs\a\+\%( \d\+\)\?/ contained
  syntax match melomotionJoin /[→⇄]/ contained
  syntax match melomotionCount /×\d\+/
  syntax match melomotionTilde / \zs\~\ze /
  syntax match melomotionBreath /\S\zs,\ze\%( \|$\)/
  syntax match melomotionVia /(\a[^)]*)/
  highlight default link melomotionNote Special
  highlight default link melomotionTitle Title
  highlight default link melomotionDate Comment
  highlight default link melomotionLabel Directory
  highlight default link melomotionPart Statement
  highlight default link melomotionJoin Delimiter
  highlight default link melomotionCount Number
  highlight default link melomotionTilde Delimiter
  highlight default link melomotionBreath Delimiter
  highlight default link melomotionVia Comment
]])

vim.b.current_syntax = "melomotion"
