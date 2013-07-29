class AddTypeToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :response_type, :string
    add_index  :responses, [:edition_id, :response_type]
  end
end
