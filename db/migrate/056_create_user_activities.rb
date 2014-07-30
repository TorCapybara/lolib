class CreateUserActivities < ActiveRecord::Migration
  def change
    create_table :user_activities do |t|
      t.integer :user_id
      t.string :request_url
      t.string :user_agent
      t.string :referer

      t.timestamps
    end
  end
end
