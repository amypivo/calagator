class AddKeyToEvents < ActiveRecord::Migration
  def change
    add_column :events, :key, :string
  end
end
