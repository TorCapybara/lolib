class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name

      t.timestamps
    end

    create_table :tokens do |t|
      t.string :name

      t.timestamps
    end

    create_table :roles_tokens, :id => false do |t|
      t.belongs_to :role
      t.belongs_to :token
    end
  end
end
