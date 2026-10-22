-- Highlighting for the lyrics that :Melomotion show opens.
if vim.b.current_syntax then
  return
end

vim.cmd([[
  syntax match melomotionHeader /^──.*/
  syntax match melomotionVerse /^♪ .\{-}\ze\%(   ←\|$\)/
  syntax match melomotionArrow /←.*$/
  syntax match melomotionCount /×\d\+/
  highlight default link melomotionHeader Title
  highlight default link melomotionVerse Directory
  highlight default link melomotionArrow Special
  highlight default link melomotionCount Number
]])

vim.b.current_syntax = "melomotion"
