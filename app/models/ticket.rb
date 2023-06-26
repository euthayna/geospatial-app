
# require 'rgeo'
# require 'rgeo/wkt_parser'

class Ticket < ApplicationRecord
  has_one :excavator
  validates :request_number, presence: true, uniqueness: true
  validates :sequence_number, presence: true
  validates :request_type, presence: true
  validates :request_action, presence: true
  validates :response_due_date_time, presence: true
  validates :primary_service_area_code, presence: true
  validates :additional_service_area_codes, presence: true
  validates :digsite_info_well_known_text, presence: true

  before_save :format_polygon, if: -> { digsite_info_well_known_text.present? }

  def format_polygon
    self.digsite_info_well_known_text = digsite_info_well_known_text.gsub(/\s+/, ' ').gsub(/\s*,\s*/, ',')
  end
end