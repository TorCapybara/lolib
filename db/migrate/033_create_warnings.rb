class CreateWarnings < ActiveRecord::Migration
  def change
    create_table :warnings do |t|
      t.integer :user_id
      t.integer :moderator_id
      t.string :reason
    end
  end
end
