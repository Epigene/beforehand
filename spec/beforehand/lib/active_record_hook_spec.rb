# frozen_string_literal: true

RSpec.describe Beforehand::ActiveRecordHook do
  it "is mixed into ActiveRecord::Base" do
    expect(ActiveRecord::Base.ancestors).to include(described_class)
  end

  it "defines .beforehand" do
    expect(ActiveRecord::Base).to respond_to(:beforehand)
  end
end
