class String
  def colourise(code, reset_code = 39)
    # Making sure we align the correct reset codes
    if self.include?("\e[#{reset_code}m")
      result = self.gsub("\e[#{reset_code}m", "\e[#{reset_code}m\e[#{code}m")
      "\e[#{code}m#{result}\e[#{reset_code}m"
    else
      "\e[#{code}m#{self}\e[#{reset_code}m"
    end
  end

  def white = colourise(97)

  def black = colourise(30)

  def red = colourise(31)

  def green = colourise(32)

  def brown = colourise(33)

  def yellow = colourise(93)

  def blue = colourise(34)

  def magenta = colourise(35)

  def cyan = colourise(36)

  def gray = colourise(37)

  def bright_red = colourise(91)

  def bright_green = colourise(92)

  def bright_blue = colourise(94)

  def bright_magenta = colourise(95)

  def bright_cyan = colourise(96)

  def bg_black = colourise(40, 49)

  def bg_red = colourise(41, 49)

  def bg_green = colourise(42, 49)

  def bg_brown = colourise(43, 49)

  def bg_yellow = colourise(103, 49)

  def bg_blue = colourise(44, 49)

  def bg_magenta = colourise(45, 49)

  def bg_cyan = colourise(46, 49)

  def bg_gray = colourise(47, 49)

  def bg_white = colourise(107, 49)

  def bg_bright_red = colourise(101, 49)

  def bg_bright_green = colourise(102, 49)

  def bg_bright_blue = colourise(104, 49)

  def bg_bright_magenta = colourise(105, 49)

  def bg_bright_cyan = colourise(106, 49)

  def bold = colourise(1, 22)

  def dim = colourise(2, 22)

  def italic = colourise(3, 23)

  def underline = colourise(4, 24)

  def reverse_colour = colourise(7, 27)

  def strip_colour
    gsub(/\e\[[0-9;]*m/, '')
  end

  alias bg_grey bg_gray
  alias colorize colourise
  alias grey gray
  alias reverse_color reverse_colour
  alias strip_color strip_colour
end
