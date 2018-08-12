# frozen_string_literal: true

# rspec spec/beforehand/integration_spec.rb
RSpec.describe Beforehand, type: :feature do
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }

  let(:pessimistic_time_saved_by_caching) { 0.8 }
  let(:pessimistic_time_saved_by_partial_cache_preheat) { 0.4 }

  before do
    Rails.cache.clear
  end

  describe "cache preheat after record update" do
    it "preheats cache after record update", driver: :chrome do
      # 1. Checking that runtime caching works
      unheated_open_time = Benchmark.realtime do
        visit users_path
      end

      # expect(page).to have_css()

      heated_open_time = Benchmark.realtime do
        visit users_path
      end

      # Rendering the two rows takes 1s (2*0.5s) to render due to wait
      # Let's expect that caching saves us at least 0.8s
      expect(heated_open_time).to be < (unheated_open_time - pessimistic_time_saved_by_caching)

      # 2. Now clearing cache and updating one record to have it preheat
      Rails.cache.clear

      create(:payment, user: user2)

      partially_preheated_open_time = Benchmark.realtime do
        visit users_path
      end

      # expect(page).to have_css("TODO, 1 payment")

      # Rendering the two rows takes 0.5s (1*0.5s + 1*0s) to render due to wait
      # Let's expect that caching saves us at least 0.4s
      expect(partially_preheated_open_time).to be < (unheated_open_time - pessimistic_time_saved_by_partial_cache_preheat)
    end
  end

  feature "cache preheat after app boot" do
    scenario "opening the view after boot heatup is fast immediately" do
      unheated_open_time = Benchmark.realtime do
        visit users_path
      end

      # clear cache and simulate app boot
      Rails.cache.clear
      Beforehand.enqueue

      heated_open_time = Benchmark.realtime do
        visit users_path
      end

      expect(heated_open_time).to be < (unheated_open_time - pessimistic_time_saved_by_caching)
    end
  end
end
