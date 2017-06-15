class CreateSpreePaybrightContracts < SolidusSupport::Migration[4.2]
  def change
    create_table :spree_paybright_contracts do |t|
      t.string :account_id
      t.string :currency
      t.boolean :test
      t.decimal :amount
      t.string :gateway_reference
      t.string :result
      t.string :message
      t.timestamps
    end
  end
end
