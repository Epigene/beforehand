# frozen_string_literal: true

# rspec spec/beforehand/lib/beforehand_spec.rb
RSpec.describe Beforehand do
  describe ".enqueue" do
    subject(:enqueueing) { described_class.enqueue }

    it "enqueues pre-heat for models' records specified" do
    # TODO
      expect(0).to match(1)

      enqueueing
    end
  end

  describe "#cache_key(*resources, **context)" do
    subject(:cache_key) { described_class.cache_key }

    let(:wrapped_value) { "some_key" }

    before do
      allow(Beforehand::CacheKey).to receive(:call).and_return(wrapped_value)
    end

    it "wraps Beforehand::CacheKey and returns whetever it returns" do
      expect(cache_key).to eq(wrapped_value)
    end
  end
end
