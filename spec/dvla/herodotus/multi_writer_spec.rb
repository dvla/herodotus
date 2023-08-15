require 'dvla/herodotus'

RSpec.describe DVLA::Herodotus::MultiWriter do
  it 'calls write on every registered writer when write is called' do
    writer_one = instance_double(File)
    writer_two = instance_double(File)

    argument_one = 'argument one'
    argument_two = 'argument two'

    expect(writer_one).to receive(:write).with(argument_one, argument_two)
    expect(writer_two).to receive(:write).with(argument_one, argument_two)

    multi_writer = DVLA::Herodotus::MultiWriter.new(writer_one, writer_two)
    multi_writer.write(argument_one, argument_two)
  end

  it 'calls close on every registered writer when close is called' do
    writer_one = instance_double(File)
    writer_two = instance_double(File)

    expect(writer_one).to receive(:close)
    expect(writer_two).to receive(:close)

    multi_writer = DVLA::Herodotus::MultiWriter.new(writer_one, writer_two)
    multi_writer.close
  end

  it 'does not close the standard output when close is called' do
    multi_writer = DVLA::Herodotus::MultiWriter.new($stdout)
    multi_writer.close

    expect($stdout.closed?).to be false
  end
end
