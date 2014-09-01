Sequel.migration do
  up do
    create_table(:products) do
      primary_key :id
      String :name, :null => false
      column :print_specs, 'text', :null => false
      column :dimensions, 'text', :null => false
      column :software_electrical, 'text', :null => false
      column :created_at, DateTime
      column :updated_at, DateTime      
    end
  end

  down do
    drop_table(:products)
  end
end
