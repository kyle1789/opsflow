class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.integer :user_id
      t.integer :workflow_id
      t.string :title
      t.string :status

      t.timestamps
    end
  end
end
