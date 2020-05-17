class AddJtiToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :jti, :string
    # populate jti so we can make it not nullable
    Customer.all.each do |customer|
      customer.update_column(:jti, SecureRandom.uuid)
    end
    change_column_null :customers, :jti, false
    add_index :customers, :jti, unique: true
  end
end
