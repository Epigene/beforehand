# frozen_string_literal: true

# rspec spec/beforehand/lib/active_record_hook_spec.rb
RSpec.describe Beforehand::ActiveRecordHook do
  it "is mixed into ActiveRecord::Base" do
    expect(ActiveRecord::Base.ancestors).to include(described_class)
  end

  it "defines .beforehand" do
    expect(ActiveRecord::Base).to respond_to(:beforehand)
  end

  describe ".beforehand" do
    subject(:creating_a_callback) { User.beforehand(**options) }

    let(:options) { {run: run, method: method} }

    context "when the definition specifies :on_callback run behavior" do
      let(:run) { :on_callback }
      let(:method) { {} }

      it " " do
        expect(0).to eq(1)
      end

      context "when the definition specifies custom job options" do
        it " " do
          expect(0).to eq(1)
        end
      end

      context "when the definition specifies custom callback options" do
        it " " do
          expect(0).to eq(1)
        end
      end

      context "when strict options are turned off" do
        let(:method) { {name: :totally_not_defined} }

        before do
          Beforehand.configuration.strict_beforehand_options = false
        end

        it "allows a missing method in method options" do
          expect{ creating_a_callback }.to_not raise_error
        end
      end
    end

    context "when the definition specifies :on_app_init run behavior" do
      context "when " do
        it " " do
          expect(0).to eq(1)
        end
      end
    end

    context "when the definition specifies some unsupported run mode" do
      it "raises an ArgumentError" do
        expect{ creating_a_callback }.to raise_error(
          ArgumentError, %r'Fff'
        )
      end
    end
  end
end
