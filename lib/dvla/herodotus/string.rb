class String
  def black = "\e[30m#{self}\e[0m"

  def red = "\e[31m#{self}\e[0m"

  def green = "\e[32m#{self}\e[0m"

  def brown = "\e[33m#{self}\e[0m"

  def blue = "\e[34m#{self}\e[0m"

  def magenta = "\e[35m#{self}\e[0m"

  def cyan = "\e[36m#{self}\e[0m"

  def gray = "\e[37m#{self}\e[0m"

  alias grey gray

  def bright_black = "\e[90m#{self}\e[0m"

  def bright_red = "\e[91m#{self}\e[0m"

  def bright_green = "\e[92m#{self}\e[0m"

  def bright_yellow = "\e[93m#{self}\e[0m"

  def bright_blue = "\e[94m#{self}\e[0m"

  def bright_magenta = "\e[95m#{self}\e[0m"

  def bright_cyan = "\e[96m#{self}\e[0m"

  def white = "\e[97m#{self}\e[0m"

  def bg_black = "\e[40m#{self}\e[0m"

  def bg_red = "\e[41m#{self}\e[0m"

  def bg_green = "\e[42m#{self}\e[0m"

  def bg_brown = "\e[43m#{self}\e[0m"

  def bg_blue = "\e[44m#{self}\e[0m"

  def bg_magenta = "\e[45m#{self}\e[0m"

  def bg_cyan = "\e[46m#{self}\e[0m"

  def bg_gray = "\e[47m#{self}\e[0m"

  def bold = "\e[1m#{self}\e[22m"

  def italic = "\e[3m#{self}\e[23m"

  def underline = "\e[4m#{self}\e[24m"

  def blink = "\e[5m#{self}\e[25m"

  def reverse_color = "\e[7m#{self}\e[27m"
end
