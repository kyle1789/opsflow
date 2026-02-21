class CreateWorkflows < ActiveRecord::Migration[8.0]
  def change
    create_table :workflows do |t|
      t.integer :user_id
      t.integer :intent_id
      t.string :status
      t.string :title

      t.timestamps
    end
  end
end
