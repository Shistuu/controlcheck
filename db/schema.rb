# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_22_000005) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "check_runs", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.datetime "started_at", null: false
    t.datetime "finished_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_check_runs_on_organization_id"
  end

  create_table "controls", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_controls_on_key", unique: true
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.string "github_login", null: false
    t.string "public_repo_allowlist", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["github_login"], name: "index_organizations_on_github_login", unique: true
  end

  create_table "remediations", force: :cascade do |t|
    t.bigint "result_id", null: false
    t.text "draft_text", null: false
    t.string "status", default: "draft", null: false
    t.string "approved_by"
    t.datetime "approved_at"
    t.text "final_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["result_id"], name: "index_remediations_on_result_id"
  end

  create_table "results", force: :cascade do |t|
    t.bigint "check_run_id", null: false
    t.bigint "control_id", null: false
    t.boolean "passed", null: false
    t.jsonb "details", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["check_run_id", "control_id"], name: "index_results_on_check_run_id_and_control_id", unique: true
    t.index ["check_run_id"], name: "index_results_on_check_run_id"
    t.index ["control_id"], name: "index_results_on_control_id"
  end

  add_foreign_key "check_runs", "organizations"
  add_foreign_key "remediations", "results"
  add_foreign_key "results", "check_runs"
  add_foreign_key "results", "controls"
end
