class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.string :file_digest

      t.timestamps
    end
  end
end
