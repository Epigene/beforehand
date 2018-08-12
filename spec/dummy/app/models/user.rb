class User < ActiveRecord::Base
  has_many :payments, dependent: :destroy

  validates :email, presence: true, uniqueness: true

  SUPPORTED_LOCALES = ["en", "lv"].freeze

  SUPPORTED_LOCALES.each do |locale|
    # Define a callback for each variant to render
    beforehand(
      run: [:on_init, :on_callback],
      method: {
        name: :preheat_users_index_rows,
        args: [locale]
      },
      job_options: {queue: :cache_preheat}
    )
  end

  private
    # The actual method that will be invoked asynchroniously
    def preheat_users_index_rows(locale)
      cache_key = Beforehand.cache_key(self, locale: locale, in: "users/index")

      Rails.cache.fetch(cache_key) do

      end
    end
end
