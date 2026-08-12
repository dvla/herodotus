require 'dvla/herodotus'

RSpec.describe DVLA::Herodotus do
  after(:each) do
    DVLA::Herodotus.main_logger = nil
  end

  describe '.configure' do
    after(:each) do
      DVLA::Herodotus.reset_configuration!
    end

    it 'allows setting logger options' do
      DVLA::Herodotus.configure do |c|
        c.display_pid = true
        c.main = true
      end

      expect(DVLA::Herodotus.configuration.display_pid).to eq(true)
      expect(DVLA::Herodotus.configuration.main).to eq(true)
    end

    it 'allows setting semantic colours' do
      DVLA::Herodotus.configure do |c|
        c.success = :cyan
        c.warning = :red
      end

      expect(DVLA::Herodotus.configuration.success).to eq(:cyan)
      expect(DVLA::Herodotus.configuration.warning).to eq(:red)
    end

    it 'allows setting both logger options and semantic colours in one block' do
      DVLA::Herodotus.configure do |c|
        c.display_pid = true
        c.prefix_colour = { overall: :blue }
        c.success = :bright_green
        c.data = :cyan
      end

      expect(DVLA::Herodotus.configuration.display_pid).to eq(true)
      expect(DVLA::Herodotus.configuration.prefix_colour).to eq({ overall: :blue })
      expect(DVLA::Herodotus.configuration.success).to eq(:bright_green)
      expect(DVLA::Herodotus.configuration.data).to eq(:cyan)
    end

    it 'persists configuration across calls' do
      DVLA::Herodotus.configure { |c| c.display_pid = true }
      DVLA::Herodotus.configure { |c| c.success = :cyan }

      expect(DVLA::Herodotus.configuration.display_pid).to eq(true)
      expect(DVLA::Herodotus.configuration.success).to eq(:cyan)
    end

    it 'returns the configuration object' do
      result = DVLA::Herodotus.configure { |c| c.main = true }

      expect(result).to be_a(DVLA::Herodotus::Config)
      expect(result.main).to eq(true)
    end
  end

  describe '.reset_configuration!' do
    it 'resets logger options to nil' do
      DVLA::Herodotus.configure do |c|
        c.display_pid = true
        c.main = true
      end

      DVLA::Herodotus.reset_configuration!

      expect(DVLA::Herodotus.configuration.display_pid).to be_nil
      expect(DVLA::Herodotus.configuration.main).to be_nil
    end

    it 'resets semantic colours to defaults' do
      DVLA::Herodotus.configure do |c|
        c.success = :cyan
        c.warning = :red
      end

      DVLA::Herodotus.reset_configuration!

      expect(DVLA::Herodotus.configuration.success).to eq(:green)
      expect(DVLA::Herodotus.configuration.warning).to eq(:yellow)
    end
  end

  it 'returns a logger' do
    expect(DVLA::Herodotus.logger('rspec')).to be_a(Logger)
  end

  it 'should throw an error when attempting to initialize logger without a name' do
    expect { DVLA::Herodotus.logger }.to raise_error(ArgumentError)
  end

  it 'returns a logger with the expected format' do
    allow(Time).to receive(:now)
                     .and_return(Time.new(2022))
    allow(SecureRandom).to receive(:uuid)
                             .and_return('123e4567-e89b-12d3-a456-426614174000')

    logger = DVLA::Herodotus.logger('rspec')

    expect { logger.info('test') }.to output("[rspec 2022-01-01 00:00:00 123e4567] INFO -- : test\n")
                                        .to_stdout_from_any_process
  end

  it 'returns a logger that outputs the pid if it is configured' do
    allow(Time).to receive(:now).and_return(Time.new(2022))
    allow(SecureRandom).to receive(:uuid).and_return('123e4567-e89b-12d3-a456-426614174000')
    allow(Process).to receive(:pid).and_return(1234)

    config = DVLA::Herodotus.config { |c| c.display_pid = true }
    logger = DVLA::Herodotus.logger('rspec', config: config)

    expect { logger.info('test') }.to output("[rspec 2022-01-01 00:00:00 123e4567 1234] INFO -- : test\n")
                                        .to_stdout_from_any_process
  end

  it 'returns a logger that is configured to merge when that is set up' do
    allow(Time).to receive(:now).and_return(Time.new(2022))
    allow(SecureRandom).to receive(:uuid).and_return('123e4567-e89b-12d3-a456-426614174000')

    config = DVLA::Herodotus.config { |c| c.main = true }
    logger = DVLA::Herodotus.logger('rspec', config: config)

    expect(logger.main).to eq(true)
  end

  it 'returns a logger that outputs to both the standard output and a file if a string is passed in as an output_path' do
    allow(Time).to receive(:now).and_return(Time.new(2022))
    allow(SecureRandom).to receive(:uuid).and_return('123e4567-e89b-12d3-a456-426614174000')

    file_double = instance_double(File)
    expect(file_double).to receive(:write).with("[rspec 2022-01-01 00:00:00 123e4567] INFO -- : test\n")
    allow(File).to receive(:open).and_call_original
    allow(File).to receive(:open).with('example_file.txt', 'a').and_return(file_double)

    logger = DVLA::Herodotus.logger('rspec', output_path: 'example_file.txt')

    expect { logger.info('test') }.to output("[rspec 2022-01-01 00:00:00 123e4567] INFO -- : test\n")
                                        .to_stdout_from_any_process
  end

  it 'outputs to both standard output and scenario-based files -- logs WARN when HerotodusLogger not set to main' do
    allow(Time).to receive(:now).and_return(Time.new(2022))
    allow(SecureRandom).to receive(:uuid).and_return('123e4567-e89b-12d3-a456-426614174000')

    example_scenario_name = 'example_scenario'

    file_double = instance_double(File)
    expect(file_double).to receive(:write).with("[rspec 2022-01-01 00:00:00 123e4567] INFO -- : test\n")
    allow(file_double).to receive(:close)
    allow(File).to receive(:open).and_call_original
    allow(File).to receive(:open).with("#{example_scenario_name}_log.txt", 'a').and_return(file_double)

    logger = DVLA::Herodotus.logger('rspec', output_path: Proc.new { "#{@scenario}_log.txt" })
    logger.new_scenario(example_scenario_name)

    expect { logger.info('test') }.to output("[rspec 2022-01-01 00:00:00 123e4567] INFO -- : test\n")
                                        .to_stdout_from_any_process
  end

  it 'will create a directory for a string output_path if it does not exist' do
    output_path = "test-path/#{rand(9999)}/log.txt"
    expect { DVLA::Herodotus.logger('rspec', output_path: output_path) }.to_not raise_error
  end

  it 'will create a directory for a proc output_path if it does not exist' do
    output_path = Proc.new { "test-path/#{rand(9999)}/log.txt" }
    expect { DVLA::Herodotus.logger('rspec', output_path: output_path) }.to_not raise_error
  end

  it 'raises an error when an unexpected type is passed in as an output_path' do
    unexpected_int = 123
    expect { DVLA::Herodotus.logger('rspec', output_path: unexpected_int) }.to raise_error(ArgumentError, 'Unexpected output_path provided. Expecting either a string or a proc')
  end
end
