class AddParentIdToComment < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :parent_id, :bigint, null: true
    add_index :comments, :parent_id
    add_foreign_key :comments, :comments, column: :parent_id, on_delete: :cascade
  end
end
