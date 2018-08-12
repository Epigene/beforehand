class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.timestamps null: false

      t.text :email, null: false
    end

    add_index(:users, :email, unique: true)
  end
end
