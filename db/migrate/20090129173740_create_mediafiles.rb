class CreateMediafiles < ActiveRecord::Migration
  def self.up
    create_table :mediafiles, :options => 'DEFAULT CHARSET=utf8' do |t|
      t.string :title
      t.text :description
      t.string :link_alternate
      t.datetime :date
      t.integer :account_id
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :mediafiles
  end
end
