class User < ActiveRecord::Base
  has_many :payments, dependent: :destroy

  validate :email, presence: true, uniqueness: true

  after_commit :run_method { puts "with block" }

  def run_method
    yield
  end
end
