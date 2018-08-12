class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.timestamps null: false

      t.integer :user_id, null: false
      t.integer :amount, null: false
    end

    add_index(:payments, :user_id)
  end
end
