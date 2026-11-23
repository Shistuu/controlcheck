class CreateResults < ActiveRecord::Migration[8.1]
  def change
    create_table :results do |t|
      t.references :check_run, null: false, foreign_key: true
      t.references :control, null: false, foreign_key: true
      t.boolean :passed, null: false
      t.jsonb :details, null: false, default: {}
      t.timestamps
    end
    add_index :results, [ :check_run_id, :control_id ], unique: true
  end
end
