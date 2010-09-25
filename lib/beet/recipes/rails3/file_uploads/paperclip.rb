gem 'paperclip'

model_name = ask "Name of the model to add an attachment to, e.g. user_profile"
attachment_name = ask "Name for the attached file, e.g. has_attached_file :avatar"
underscored_model_name = model_name.underscore

in_root do
  if File.exists?("app/models/#{model_name}.rb")
    table_name = model_name.tableize

    generate "migration add_#{attachment_name}_to_#{table_name}"
    migration_file = Dir["db/migrate/*add_#{attachment_name}_to_#{table_name}*"].first
    add_after migration_file, 'def self.up', do
      %{
        add_column :#{table_name}, :#{attachment_name}_file_name, :string
        add_column :#{table_name}, :#{attachment_name}_content_type, :string
        add_column :#{table_name}, :#{attachment_name}_file_size, :integer
        add_column :#{table_name}, :#{attachment_name}_updated_at, :datetime
      }
    end
  else
    generate "model #{model_name} #{attachment_name}_file_name:string #{attachment_name}_content_type:string #{attachment_name}_file_size:integer #{attachment_name}_updated_at:datetime"
  end

  add_after "app/models/#{underscored_model_name}.rb", "class #{model_name.camelize} < ActiveRecord::Base",  "has_attached_file :#{attachment_name}, :styles => { :thumb => '50x' }"

end

rake "db:migrate"
