local wezterm = require "wezterm"
return {
  color_scheme = "Dracula (Official)",
  font = wezterm.font "FiraCode Nerd Font",
  front_end = "WebGpu",
  tab_bar_at_bottom = true,
  window_close_confirmation = "NeverPrompt",
  window_decorations = "RESIZE",
}
