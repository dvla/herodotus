require 'dvla/herodotus/semantic_colours'

RSpec.describe DVLA::Herodotus::SemanticColours do
  after(:each) do
    described_class.reset!
  end

  describe 'default colours' do
    it 'has brown as the default config colour' do
      expect(described_class.config).to eq(:brown)
    end

    it 'has magenta as the default step colour' do
      expect(described_class.step).to eq(:magenta)
    end

    it 'has green as the default success colour' do
      expect(described_class.success).to eq(:green)
    end

    it 'has yellow as the default warning colour' do
      expect(described_class.warning).to eq(:yellow)
    end

    it 'has blue as the default data colour' do
      expect(described_class.data).to eq(:blue)
    end
  end

  describe '.configure' do
    it 'allows overriding the config colour' do
      described_class.configure do |c|
        c.config = :cyan
      end

      expect(described_class.config).to eq(:cyan)
    end

    it 'allows overriding multiple colours' do
      described_class.configure do |c|
        c.step = :blue
        c.warning = :red
      end

      expect(described_class.step).to eq(:blue)
      expect(described_class.warning).to eq(:red)
    end

    it 'preserves unmodified colours' do
      described_class.configure do |c|
        c.success = :bright_green
      end

      expect(described_class.config).to eq(:brown)
      expect(described_class.step).to eq(:magenta)
      expect(described_class.success).to eq(:bright_green)
    end
  end

  describe '.reset!' do
    it 'restores all colours to defaults' do
      described_class.configure do |c|
        c.config = :red
        c.step = :blue
        c.success = :cyan
        c.warning = :magenta
        c.data = :green
      end

      described_class.reset!

      expect(described_class.config).to eq(:brown)
      expect(described_class.step).to eq(:magenta)
      expect(described_class.success).to eq(:green)
      expect(described_class.warning).to eq(:yellow)
      expect(described_class.data).to eq(:blue)
    end
  end
end
