class CreateWikis < ActiveRecord::Migration
  def change
    create_table :wikis do |t|
      t.string :name
      t.integer :viewed

      t.timestamps
    end

    create_table :wiki_revisions do |t|
      t.text :content
      t.integer :revision
      t.integer :user_id
      t.integer :wiki_id

      t.timestamps
    end
  end
end
