Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      String :email, :null => false
      column :id_rsa, 'text', :null => false
      String :salt, :null => false
      String :api_key, :null => false
    end
    
  end

  down do
    drop_table(:users)
  end
end
