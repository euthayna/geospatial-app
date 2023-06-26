class CreateTicketsAndExcavators < ActiveRecord::Migration[7.0]
  def change
    create_table :tickets do |t|
      t.string :request_number
      t.string :sequence_number
      t.string :request_type
      t.string :request_action
      t.datetime :response_due_date_time
      t.string :primary_service_area_code
      t.text :additional_service_area_codes
      t.string :digsite_info_well_known_text

      t.timestamps
    end

    create_table :excavators do |t|
      t.references :ticket, null: false, foreign_key: true
      t.string :company_name
      t.text :address
      t.boolean :crew_on_site

      t.timestamps
    end
  end
end
