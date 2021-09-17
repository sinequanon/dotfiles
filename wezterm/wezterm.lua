local wezterm = require 'wezterm';
return {
  font = wezterm.font("OperatorMonoSSmLig Nerd Font");
  font_size = 15.0;
  line_height = 1.75;
  color_scheme = "Gruvbox Dark";
  enable_tab_bar = false;
  enable_scroll_bar = true;
  window_padding = {
    -- left = 4,
    -- right = 4,
    top = 20,
    -- bottom = 4,
  };
  text_background_opacity = 0.0;
}
