# frozen_string_literal: true

# rspec spec/beforehand/lib/beforehand_spec.rb
RSpec.describe Beforehand do
  describe ".enqueue" do
    subject(:enqueueing) { described_class.enqueue }

    context "when the ENV switch is not passed" do
      it "does nothing" do
        expect(enqueueing).to be_nil
      end
    end

    context "when the ENV switch is passed" do
      it "enqueues pre-heat for models' records specified in order of priority" do
      # TODO
        expect(0).to match(1)

        enqueueing
      end
    end
  end

  describe ".cache_key(*resources, **context)" do
    subject(:cache_key) { described_class.cache_key }

    let(:wrapped_value) { "some_key" }

    before do
      allow(Beforehand::CacheKey).to receive(:call).and_return(wrapped_value)
    end

    it "wraps Beforehand::CacheKey and returns whetever it returns" do
      expect(cache_key).to eq(wrapped_value)
    end
  end

  describe ".configure" do
    subject(:configuring) do
      described_class.configure do |config|
        config.verbose = true
        config.anti_dogpile_threshold = 1.minute
        config.strict_beforehand_options = true
      end
    end

    it "allows configuring the global options" do
      expect{ configuring }.to(
        change{ described_class.configuration.verbose }.from(false).to(true)
      )
    end
  end
end
