require 'dvla/herodotus'

RSpec.describe DVLA::Herodotus::HerodotusLogger do
  let(:logger) { DVLA::Herodotus.logger }

  after(:each) do
    DVLA::Herodotus.configure do |config|
      config.system_name = nil
      config.merge = false
    end
  end

  [
    { method: :debug, string_value: 'DEBUG' },
    { method: :info, string_value: 'INFO' },
    { method: :warn, string_value: 'WARN' },
    { method: :error, string_value: 'ERROR' },
    { method: :fatal, string_value: 'FATAL' },
  ].each do |testcase|
    it 'logs with the same correlation id when no scenario name is passed in' do
      allow(Time).to receive(:now)
                       .and_return(Time.new(2022))
      allow(SecureRandom).to receive(:uuid)
                               .and_return('123e4567-e89b-12d3-a456-426614174000', '00112233-4455-6677-8899-aabbccddeeff')

      expect { logger.send(testcase[:method], 'First Log') }.to output("[2022-01-01 00:00:00 123e4567] #{testcase[:string_value]} -- : First Log\n")
                                          .to_stdout_from_any_process
      expect { logger.send(testcase[:method], 'Second Log') }.to output("[2022-01-01 00:00:00 123e4567] #{testcase[:string_value]} -- : Second Log\n")
                                               .to_stdout_from_any_process
    end

    it 'logs with the same correlation id when a scenario name is passed in' do
      allow(Time).to receive(:now)
                       .and_return(Time.new(2022))
      allow(SecureRandom).to receive(:uuid)
                               .and_return('123e4567-e89b-12d3-a456-426614174000', '00112233-4455-6677-8899-aabbccddeeff')

      expect { logger.send(testcase[:method], 'First Log', 'Scenario One') }.to output("[2022-01-01 00:00:00 00112233] #{testcase[:string_value]} -- : First Log\n")
                                                                 .to_stdout_from_any_process
      expect { logger.send(testcase[:method], 'Second Log', 'Scenario One') }.to output("[2022-01-01 00:00:00 00112233] #{testcase[:string_value]} -- : Second Log\n")
                                                                   .to_stdout_from_any_process
    end

    it 'logs with the different correlation id when different scenario names is passed in' do
      allow(Time).to receive(:now)
                       .and_return(Time.new(2022))
      allow(SecureRandom).to receive(:uuid)
                               .and_return('123e4567-e89b-12d3-a456-426614174000', '00112233-4455-6677-8899-aabbccddeeff', '00000000-0000-0000-0000-000000000000')

      expect { logger.send(testcase[:method], 'First Log', 'Scenario One') }.to output("[2022-01-01 00:00:00 00112233] #{testcase[:string_value]} -- : First Log\n")
                                                                                 .to_stdout_from_any_process
      expect { logger.send(testcase[:method], 'Second Log', 'Scenario Two') }.to output("[2022-01-01 00:00:00 00000000] #{testcase[:string_value]} -- : Second Log\n")
                                                                                   .to_stdout_from_any_process
    end

    it 'logs with the different correlation id when new_scenario is called' do
      allow(Time).to receive(:now)
                       .and_return(Time.new(2022))
      allow(SecureRandom).to receive(:uuid)
                               .and_return('123e4567-e89b-12d3-a456-426614174000', '00112233-4455-6677-8899-aabbccddeeff')

      expect { logger.send(testcase[:method], 'First Log') }.to output("[2022-01-01 00:00:00 123e4567] #{testcase[:string_value]} -- : First Log\n")
                                                                                 .to_stdout_from_any_process
      logger.new_scenario('scenario_id')
      expect { logger.send(testcase[:method], 'Second Log') }.to output("[2022-01-01 00:00:00 00112233] #{testcase[:string_value]} -- : Second Log\n")
                                                                                   .to_stdout_from_any_process
    end

    it 'logs a block that is passed in' do
      allow(Time).to receive(:now)
                       .and_return(Time.new(2022))
      allow(SecureRandom).to receive(:uuid)
                               .and_return('123e4567-e89b-12d3-a456-426614174000', '00112233-4455-6677-8899-aabbccddeeff')

      expect { logger.send(testcase[:method]) { 'Test Log' } }.to output("[2022-01-01 00:00:00 123e4567] #{testcase[:string_value]} -- : Test Log\n")
                                                                 .to_stdout_from_any_process
    end
  end

  it 'starts a new scenario with the non-default correlation id every time new_scenario is called' do
    allow(Time).to receive(:now)
                     .and_return(Time.new(2022))
    allow(SecureRandom).to receive(:uuid)
                             .and_return('123e4567-e89b-12d3-a456-426614174000', '00112233-4455-6677-8899-aabbccddeeff', 'e19f77a7-337c-47a8-93a9-c2180040ba03')

    logger.new_scenario('name of the new scenario')
    expect { logger.info('Test Log') }.to output("[2022-01-01 00:00:00 00112233] INFO -- : Test Log\n")
                                                                .to_stdout_from_any_process

    logger.new_scenario('name of another new scenario')
    expect { logger.info('Test Log') }.to output("[2022-01-01 00:00:00 e19f77a7] INFO -- : Test Log\n")
                                            .to_stdout_from_any_process
  end

  it 'overrides the correlation ids of other loggers when merge_correlation_ids is called' do
    other_logger = DVLA::Herodotus.logger

    logger.merge_correlation_ids

    expect(logger.correlation_ids).to eq(other_logger.correlation_ids)
  end

  it 'does not override the system name of other loggers when merge_correlation_ids is called' do
    DVLA::Herodotus.configure do |config|
      config.system_name = 'system name'
    end

    other_logger = DVLA::Herodotus.logger

    DVLA::Herodotus.configure do |config|
      config.system_name = 'different system name'
    end

    logger.merge_correlation_ids

    expect(logger.system_name).not_to eq(other_logger.system_name)
  end

  it 'overrides the correlation ids of other loggers when merge_correlation_ids is called on a logger that is configured to merge' do
    other_logger = DVLA::Herodotus.logger

    DVLA::Herodotus.configure do |config|
      config.merge = true
    end

    logger.new_scenario('new scenario name')

    expect(logger.correlation_ids).to eq(other_logger.correlation_ids)
  end

  it 'does not get caught in an infinite loop of merging when multiple loggers are set to merge' do
    DVLA::Herodotus.configure do |config|
      config.merge = true
    end

    _other_logger = DVLA::Herodotus.logger

    expect { logger.new_scenario('new scenario name') }.not_to raise_error
  end
end
