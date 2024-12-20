class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :name

      t.timestamps
    end
    add_index :accounts, :name, unique: true
  end
end
