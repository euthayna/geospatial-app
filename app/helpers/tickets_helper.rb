module TicketsHelper
  def crew_on_site_status(ticket)
    ticket.excavator.crew_on_site? ? 'Yes' : 'No'
  end
end
