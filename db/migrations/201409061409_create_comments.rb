Sequel.migration do
  up do
    create_table(:comments) do
      primary_key :id
      Integer :post_id
      column :comment, 'text', :null => false
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:comments)
  end
end
