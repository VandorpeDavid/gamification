class CreateCoders < ActiveRecord::Migration
  def change
    create_table :coders do |t|
      t.string :github_name
      t.string :full_name
      t.string :avatar_url
      t.integer :reward_residual
      t.integer :bounty_residual
      t.integer :bounty_score
      t.integer :other_score

      t.timestamps
    end
  end
end