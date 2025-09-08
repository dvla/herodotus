class String
  def colourise(code, reset_code = 39)
    "\e[#{code}m#{self}\e[#{reset_code}m"
  end
  alias colourise colorize

  def black = colourise(30)
  def red = colourise(31)
  def green = colourise(32)
  def brown = colourise(33)
  alias yellow brown

  def blue = colourise(34)
  def magenta = colourise(35)
  def cyan = colourise(36)
  def gray = colourise(37)
  alias grey gray

  def bright_black = colourise(90)
  def bright_red = colourise(91)
  def bright_green = colourise(92)
  def bright_yellow = colourise(93)
  def bright_blue = colourise(94)
  def bright_magenta = colourise(95)
  def bright_cyan = colourise(96)
  def white = colourise(97)

  def bg_black = colourise(40, 49)
  def bg_red = colourise(41, 49)
  def bg_green = colourise(42, 49)
  def bg_brown = colourise(43, 49)
  def bg_blue = colourise(44, 49)
  def bg_magenta = colourise(45, 49)
  def bg_cyan = colourise(46, 49)
  def bg_gray = colourise(47, 49)

  def bold = colourise(1, 22)
  def italic = colourise(3, 23)
  def underline = colourise(4, 24)
  def blink = colourise(5, 25)
  def reverse_color = colourise(7, 27)
  alias reverse_colour reverse_color
end
