require 'dvla/herodotus'

RSpec.describe DVLA::Herodotus do
  before(:each) do
    DVLA::Herodotus.configure do |config|
      config.system_name = nil
      config.pid = nil
      config.merge = nil
    end
  end

  it 'returns a logger' do
    expect(DVLA::Herodotus.logger).to be_a(Logger)
  end

  it 'returns a logger with the expected format' do
    allow(Time).to receive(:now)
                     .and_return(Time.new(2022))
    allow(SecureRandom).to receive(:uuid)
                             .and_return('123e4567-e89b-12d3-a456-426614174000')

    logger = DVLA::Herodotus.logger

    expect { logger.info('test') }.to output("[2022-01-01 00:00:00 123e4567] INFO -- : test\n")
                                        .to_stdout_from_any_process
  end

  it 'returns a logger that outputs a system name if one is configured' do
    DVLA::Herodotus.configure do |config|
      config.system_name = 'Test System Name'
    end
    allow(Time).to receive(:now)
                     .and_return(Time.new(2022))
    allow(SecureRandom).to receive(:uuid)
                             .and_return('123e4567-e89b-12d3-a456-426614174000')

    logger = DVLA::Herodotus.logger

    expect { logger.info('test') }.to output("[Test System Name 2022-01-01 00:00:00 123e4567] INFO -- : test\n")
                                        .to_stdout_from_any_process
  end

  it 'returns a logger that outputs the pid if it is configured' do
    DVLA::Herodotus.configure do |config|
      config.pid = true
    end
    allow(Time).to receive(:now)
                     .and_return(Time.new(2022))
    allow(SecureRandom).to receive(:uuid)
                             .and_return('123e4567-e89b-12d3-a456-426614174000')
    allow(Process).to receive(:pid)
                        .and_return(1234)

    logger = DVLA::Herodotus.logger

    expect { logger.info('test') }.to output("[2022-01-01 00:00:00 123e4567 1234] INFO -- : test\n")
                                        .to_stdout_from_any_process
  end

  it 'returns a logger that is configured to merge when that is set up' do
    DVLA::Herodotus.configure do |config|
      config.merge = true
    end
    allow(Time).to receive(:now)
                     .and_return(Time.new(2022))
    allow(SecureRandom).to receive(:uuid)
                             .and_return('123e4567-e89b-12d3-a456-426614174000')

    logger = DVLA::Herodotus.logger

    expect(logger.merge).to eq(true)
  end

  it 'returns a logger that outputs both the system name and the pid if it is configured' do
    DVLA::Herodotus.configure do |config|
      config.system_name = 'Test System Name'
      config.pid = true
    end
    allow(Time).to receive(:now)
                     .and_return(Time.new(2022))
    allow(SecureRandom).to receive(:uuid)
                             .and_return('123e4567-e89b-12d3-a456-426614174000')
    allow(Process).to receive(:pid)
                        .and_return(1234)

    logger = DVLA::Herodotus.logger

    expect { logger.info('test') }.to output("[Test System Name 2022-01-01 00:00:00 123e4567 1234] INFO -- : test\n")
                                        .to_stdout_from_any_process
  end

  it 'returns a logger that outputs to both the standard output and a file if an output_path is passed in' do
    allow(Time).to receive(:now)
                     .and_return(Time.new(2022))
    allow(SecureRandom).to receive(:uuid)
                             .and_return('123e4567-e89b-12d3-a456-426614174000')
    allow(Process).to receive(:pid)
                        .and_return(1234)

    file_double = instance_double(File)
    expect(file_double).to receive(:write).with("[2022-01-01 00:00:00 123e4567] INFO -- : test\n")
    allow(File).to receive(:open).and_call_original
    allow(File).to receive(:open).with('example_file.txt', 'a+').and_return(file_double)

    logger = DVLA::Herodotus.logger(output_path: 'example_file.txt')

    expect { logger.info('test') }.to output("[2022-01-01 00:00:00 123e4567] INFO -- : test\n")
                                        .to_stdout_from_any_process
  end
end
