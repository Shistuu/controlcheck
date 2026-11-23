class CreateCheckRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :check_runs do |t|
      t.references :organization, null: false, foreign_key: true
      t.datetime :started_at, null: false
      t.datetime :finished_at
      t.timestamps
    end
  end
end
