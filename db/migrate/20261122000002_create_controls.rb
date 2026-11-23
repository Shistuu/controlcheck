class CreateControls < ActiveRecord::Migration[8.1]
  def change
    create_table :controls do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps
    end
    add_index :controls, :key, unique: true
  end
end
