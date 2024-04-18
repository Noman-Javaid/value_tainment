class CreateContactFormSubmissions < ActiveRecord::Migration[6.1]
  def change
    create_table :contact_form_submissions do |t|
      t.string :name
      t.string :email
      t.string :title
      t.text :message

      t.timestamps
    end
  end
end
