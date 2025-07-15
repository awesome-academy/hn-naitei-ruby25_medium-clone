class AddFieldsToUSers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :address, :string
    add_column :users, :phone_number, :string
    add_column :users, :date_of_birth, :date
    add_column :users, :bio, :text
    add_column :users, :is_admin, :boolean, default: false
    add_column :users, :is_active, :boolean, default: true
    add_column :users, :last_login_at, :datetime
  end
end
