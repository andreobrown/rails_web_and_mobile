class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :item
      t.integer :quantity
      t.string :status, default: "new"

      t.timestamps
    end
  end
end
