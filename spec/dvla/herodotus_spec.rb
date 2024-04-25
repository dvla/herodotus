require 'dvla/herodotus'

RSpec.describe DVLA::Herodotus do
  after(:each) do
    DVLA::Herodotus.main_logger = nil
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

  it 'raises an error when an unexpected type is passed in as an output_path' do
    unexpected_int = 123
    expect { DVLA::Herodotus.logger('rspec', output_path: unexpected_int) }.to raise_error(ArgumentError, 'Unexpected output_path provided. Expecting either a string or a proc')
  end
end
