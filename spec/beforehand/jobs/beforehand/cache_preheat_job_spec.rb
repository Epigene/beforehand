# frozen_string_literal: true

# rspec spec/beforehand/jobs/beforehand/cache_preheat_job_spec.rb
RSpec.describe Beforehand::CachePreheatJob do
  describe "#perform(klass, id, method, *args)" do
    subject(:doing_work) { described_class.perform_later(klass, id, method, *args) }

    let(:klass) { "User" }
    let(:id) { user.id }
    let(:method) { "TODO" }
    let(:args) { ["lv"] }

    it "triggers the required method on the required instance" do
      expect(user).to receive(:TODO).with(*args).once

      doing_work
    end
  end
end



