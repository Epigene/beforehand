# frozen_string_literal: true

# rspec spec/beforehand/lib/active_record_hook_spec.rb
RSpec.describe Beforehand::ActiveRecordHook do
  it "is mixed into ActiveRecord::Base" do
    expect(ActiveRecord::Base.ancestors).to include(described_class)
  end

  it "defines .beforehand" do
    expect(ActiveRecord::Base).to respond_to(:beforehand)
  end
end
