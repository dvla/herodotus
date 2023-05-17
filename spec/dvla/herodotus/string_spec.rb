require 'dvla/herodotus/string'

RSpec.describe String do
  [
    { method: :black, expected_output: "\e[30mTest String\e[0m" },
    { method: :red, expected_output: "\e[31mTest String\e[0m" },
    { method: :green, expected_output: "\e[32mTest String\e[0m" },
    { method: :brown, expected_output: "\e[33mTest String\e[0m" },
    { method: :blue, expected_output: "\e[34mTest String\e[0m" },
    { method: :magenta, expected_output: "\e[35mTest String\e[0m" },
    { method: :cyan, expected_output: "\e[36mTest String\e[0m" },
    { method: :gray, expected_output: "\e[37mTest String\e[0m" },
    { method: :bg_black, expected_output: "\e[40mTest String\e[0m" },
    { method: :bg_red, expected_output: "\e[41mTest String\e[0m" },
    { method: :bg_green, expected_output: "\e[42mTest String\e[0m" },
    { method: :bg_brown, expected_output: "\e[43mTest String\e[0m" },
    { method: :bg_blue, expected_output: "\e[44mTest String\e[0m" },
    { method: :bg_magenta, expected_output: "\e[45mTest String\e[0m" },
    { method: :bg_cyan, expected_output: "\e[46mTest String\e[0m" },
    { method: :bg_gray, expected_output: "\e[47mTest String\e[0m" },
    { method: :bold, expected_output: "\e[1mTest String\e[22m" },
    { method: :italic, expected_output: "\e[3mTest String\e[23m" },
    { method: :underline, expected_output: "\e[4mTest String\e[24m" },
    { method: :blink, expected_output: "\e[5mTest String\e[25m" },
    { method: :reverse_color, expected_output: "\e[7mTest String\e[27m" },
  ].each do |testcase|
    it 'applies the expected formatting to a string' do
      result = 'Test String'.send(testcase[:method])

      expect(result).to eq(testcase[:expected_output])
    end
  end
end
