class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :invitation_code
      t.integer :mentor_id
      t.integer :user_id

      t.timestamps
    end
  end
end
