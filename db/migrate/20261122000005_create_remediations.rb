class CreateRemediations < ActiveRecord::Migration[8.1]
  def change
    create_table :remediations do |t|
      t.references :result, null: false, foreign_key: true
      t.text :draft_text, null: false
      t.string :status, null: false, default: "draft"
      t.string :approved_by
      t.datetime :approved_at
      t.text :final_text
      t.timestamps
    end
  end
end
