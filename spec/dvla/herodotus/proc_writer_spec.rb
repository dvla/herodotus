require 'dvla/herodotus'

RSpec.describe DVLA::Herodotus::ProcWriter do
  it 'writes to a file with the name the provided proc returns' do
    log_message = 'Example log message'

    expected_filename = 'test_log_file.txt'
    filename_proc = Proc.new { expected_filename }
    proc_writer = DVLA::Herodotus::ProcWriter.new(filename_proc)

    file_double = instance_double(File)
    expect(file_double).to receive(:write).with(log_message)
    allow(file_double).to receive(:close)
    allow(File).to receive(:open).and_call_original
    allow(File).to receive(:open).with(expected_filename, 'a').and_return(file_double)

    proc_writer.write(log_message)
  end

  it 'correctly interpolates the file name from the provided proc to write the log' do
    log_message = 'Example log message'

    expected_filename = 'expected_filename.txt'
    filename_proc = Proc.new { "#{@scenario}.txt" }
    proc_writer = DVLA::Herodotus::ProcWriter.new(filename_proc)
    proc_writer.scenario = 'expected_filename'

    file_double = instance_double(File)
    allow(File).to receive(:open).with(expected_filename, 'a').and_return(file_double)
    expect(file_double).to receive(:write).with(log_message)
    allow(file_double).to receive(:close)

    proc_writer.write(log_message)
  end
end