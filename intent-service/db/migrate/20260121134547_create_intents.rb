class CreateIntents < ActiveRecord::Migration[8.0]
  def change
    create_table :intents do |t|
      t.integer :user_id
      t.text :text
      t.string :status

      t.timestamps
    end
  end
end
