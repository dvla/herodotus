require 'dvla/herodotus/string'

RSpec.describe String do
  [
    { method: :black, expected_output: "\e[30mTest String\e[39m" },
    { method: :red, expected_output: "\e[31mTest String\e[39m" },
    { method: :green, expected_output: "\e[32mTest String\e[39m" },
    { method: :brown, expected_output: "\e[33mTest String\e[39m" },
    { method: :yellow, expected_output: "\e[93mTest String\e[39m" },
    { method: :blue, expected_output: "\e[34mTest String\e[39m" },
    { method: :magenta, expected_output: "\e[35mTest String\e[39m" },
    { method: :cyan, expected_output: "\e[36mTest String\e[39m" },
    { method: :gray, expected_output: "\e[37mTest String\e[39m" },
    { method: :white, expected_output: "\e[97mTest String\e[39m" },
    { method: :bright_red, expected_output: "\e[91mTest String\e[39m" },
    { method: :bright_green, expected_output: "\e[92mTest String\e[39m" },
    { method: :bright_blue, expected_output: "\e[94mTest String\e[39m" },
    { method: :bright_magenta, expected_output: "\e[95mTest String\e[39m" },
    { method: :bright_cyan, expected_output: "\e[96mTest String\e[39m" },
    { method: :bg_black, expected_output: "\e[40mTest String\e[49m" },
    { method: :bg_red, expected_output: "\e[41mTest String\e[49m" },
    { method: :bg_green, expected_output: "\e[42mTest String\e[49m" },
    { method: :bg_brown, expected_output: "\e[43mTest String\e[49m" },
    { method: :bg_yellow, expected_output: "\e[103mTest String\e[49m" },
    { method: :bg_blue, expected_output: "\e[44mTest String\e[49m" },
    { method: :bg_magenta, expected_output: "\e[45mTest String\e[49m" },
    { method: :bg_cyan, expected_output: "\e[46mTest String\e[49m" },
    { method: :bg_gray, expected_output: "\e[47mTest String\e[49m" },
    { method: :bg_white, expected_output: "\e[107mTest String\e[49m" },
    { method: :bg_bright_red, expected_output: "\e[101mTest String\e[49m" },
    { method: :bg_bright_green, expected_output: "\e[102mTest String\e[49m" },
    { method: :bg_bright_blue, expected_output: "\e[104mTest String\e[49m" },
    { method: :bg_bright_magenta, expected_output: "\e[105mTest String\e[49m" },
    { method: :bg_bright_cyan, expected_output: "\e[106mTest String\e[49m" },
    { method: :bold, expected_output: "\e[1mTest String\e[22m" },
    { method: :dim, expected_output: "\e[2mTest String\e[22m" },
    { method: :italic, expected_output: "\e[3mTest String\e[23m" },
    { method: :underline, expected_output: "\e[4mTest String\e[24m" },
    { method: :reverse_colour, expected_output: "\e[7mTest String\e[27m" },
  ].each do |testcase|
    it 'applies the expected formatting to a string' do
      result = 'Test String'.send(testcase[:method])

      expect(result).to eq(testcase[:expected_output])
    end
  end

  describe 'strip_colour' do
    it 'removes ANSI colour codes from strings' do
      coloured_string = "\e[31m\e[1mRed Bold Text\e[22m\e[39m"
      expect(coloured_string.strip_colour).to eq('Red Bold Text')
    end

    it 'handles complex nested colours' do
      complex_string = "\e[31mRed \e[32mGreen\e[39m Red Again\e[39m"
      expect(complex_string.strip_colour).to eq('Red Green Red Again')
    end
  end

  describe 'colour combinations' do
    it 'chains multiple styles correctly' do
      expect('Test'.red.bold.underline).to eq "\e[4m\e[1m\e[31mTest\e[39m\e[22m\e[24m"
    end

    it 'combines foreground and background colours' do
      expect('Test'.white.bg_red).to eq "\e[41m\e[97mTest\e[39m\e[49m"
    end

    it 'handles bright colours with styles' do
      expect('Test'.bright_blue.bold.italic).to eq "\e[3m\e[1m\e[94mTest\e[39m\e[22m\e[23m"
    end

    it 'works with reverse and other styles' do
      expect('Test'.red.bg_yellow.reverse_colour.bold).to eq "\e[1m\e[7m\e[103m\e[31mTest\e[39m\e[49m\e[27m\e[22m"
    end
  end
end
