if vim.g.neovide then
  -- Window Bar
  vim.g.neovide_title_background_color = string.format( "%x",1184541) -- Highlight: BufferLineFill
  vim.g.neovide_title_text_color = "gray"
  vim.g.neovide_fullscreen = true
  vim.g.neovide_refresh_rate = 120
  -- Window Padding
  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 0
  vim.g.neovide_padding_left = 0
  -- Font
  vim.o.guifont = "JetBrainsMono Nerd Font"
  vim.g.neovide_scale_factor = .8
  -- Particles
  vim.g.neovide_cursor_vfx_mode = "pixiedust"
  -- Float Blur
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0
  -- Float Shadow
  vim.g.neovide_floating_shadow = false
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_light_angle_degrees = 45
  vim.g.neovide_light_radius = 5
  -- Animation Length
  vim.g.neovide_position_animation_length = .15
  vim.g.neovide_scroll_animation_length = 0.3
  vim.g.neovide_scroll_animation_far_lines = 1

  -- Cursor
  vim.g.neovide_cursor_animation_length = .13
  vim.g.neovide_cursor_trail_size = .5

  -- Particles
  vim.g.neovide_cursor_vfx_mode = "pixiedust" -- "railgun", "torpedo", "pixiedust", "sonicboom", "ripple", "wireframe",
  vim.g.neovide_cursor_vfx_opacity = 200.0
  vim.g.neovide_cursor_vfx_particle_lifetime = 1.2
  vim.g.neovide_cursor_vfx_particle_density = 7.0
  vim.g.neovide_cursor_vfx_particle_speed = 10.0
  vim.g.neovide_cursor_vfx_particle_phase = 1.5
  vim.g.neovide_cursor_vfx_particle_curl = 1.0
  -- Cool Stuff idk 
  vim.g.neovide_profiler = false
end
