# frozen_string_literal: true

# rspec spec/beforehand/lib/cache_key_spec.rb
RSpec.describe Beforehand::CacheKey do
  describe ".call(*resources, **context)" do
    subject(:calling) { described_class.call(*resources, **contexts) }

    let(:resources) { [user, payment] }
    let(:contexts) { {locale: "lv", in: "users/index"} }

    let(:user) { build_stubbed(:user) }
    let(:payment) { build_stubbed(:payment) }

    before do
      allow(user).to receive(:cache_key).and_return(
        "users/1-20180703133828000000000"
      )

      allow(payment).to receive(:cache_key).and_return(
        "payments/2-20180703133828000000000"
      )
    end

    it "generates a cache-key given resource(s) and context(s), order insensitively" do
      expect(calling).to eq(
        "[[:in, \"users/index\"], [:locale, \"lv\"]]:"\
        "payments/2-20180703133828000000000+users/1-20180703133828000000000"
      )

      # same keys even when reversing args
      expect(described_class.call(*resources, **contexts)).to eq(
        described_class.call(*resources.reverse, **contexts.to_a.reverse.to_h)
      )
    end
  end
end
