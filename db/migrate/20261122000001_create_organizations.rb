class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :github_login, null: false
      t.string :public_repo_allowlist, array: true, null: false, default: []
      t.timestamps
    end
    add_index :organizations, :github_login, unique: true
  end
end
