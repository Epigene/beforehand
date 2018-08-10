# frozen_string_literal: true

RSpec.describe Beforehand do
  describe ".enqueue" do
    subject(:enqueueing) { described_class.enqueue }

    it "enqueues pre-heat for models' records specified" do
    # TODO
      expect(0).to match(1)

      enqueueing
    end
  end
end
