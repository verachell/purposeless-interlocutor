class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.string :description, limit: 200
      t.boolean :computer

      t.timestamps
    end
  end
end
