class TicketSerializer
  def initialize(ticket)
    @ticket = ticket
  end

  def as_json(*)
    {
      id: @ticket.id,
      request_number: @ticket.request_number,
      sequence_number: @ticket.sequence_number,
      request_type: @ticket.request_type,
      request_action: @ticket.request_action,
      response_due_date_time: @ticket.response_due_date_time,
      primary_service_area_code: @ticket.primary_service_area_code,
      additional_service_area_codes: @ticket.additional_service_area_codes,
      digsite_info_well_known_text: @ticket.digsite_info_well_known_text
    }
  end
end