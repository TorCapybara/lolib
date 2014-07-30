class CreatePrivateMessages < ActiveRecord::Migration
  def change
    create_table :private_messages do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.string :subject
      t.string :text
      t.boolean :read
      t.integer :reply_id

      t.timestamps
    end
  end
end
