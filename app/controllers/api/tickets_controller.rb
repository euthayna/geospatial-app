module Api
  class TicketsController < ApplicationController
    class SaveFailure < StandardError; end

    skip_before_action :verify_authenticity_token
    before_action :check_address_data, only: :create

    def create
      attributes = ticket_data.slice('request_number', 'sequence_number', 'request_type', 'request_action')
      attributes.merge!(fill_ticket_data(ticket_data))

      Ticket.transaction do
        ticket = Ticket.new(attributes)

        raise SaveFailure, ticket.errors.full_messages.to_json unless ticket.save

        format_excavator_payload = ticket_data['excavator']
        excavator = initialize_excavator(format_excavator_payload, ticket)

        raise SaveFailure, excavator.errors.full_messages.to_json unless excavator.save

        render json: {
          status: 'success',
          ticket: TicketSerializer.new(ticket).as_json,
          excavator: ExcavatorSerializer.new(excavator).as_json
        }, status: :created

      end
    rescue SaveFailure => e
      render json: { errors: JSON.parse(e.message) }, status: :unprocessable_entity
    end

    private

    def check_address_data
      excavator_hash = ticket_data['excavator']

      errors = []
      errors << 'Address is required' if excavator_hash[:address].blank?
      errors << 'City key is required' if excavator_hash[:city].blank?
      errors << 'State key is required' if excavator_hash[:state].blank?
      errors << 'Zip key is required' if excavator_hash[:zip].blank?

      return if errors.empty?

      render json: { errors: errors }, status: :unprocessable_entity
    end

    def excavator_address_format(data)
      [data['address'], data['city'], data['state'], data['zip']].compact.join(', ')
    end

    def fill_ticket_data(data)
      {
        response_due_date_time: data.dig('date_times', 'response_due_date_time'),
        primary_service_area_code: data.dig('service_area', 'primary_service_area_code', 'sa_code'),
        additional_service_area_codes: data.dig('service_area', 'additional_service_area_codes', 'sa_code')&.join(', '),
        digsite_info_well_known_text: data.dig('excavation_info', 'digsite_info', 'well_known_text')
      }
    end

    def initialize_excavator(data, ticket)
      Excavator.new(
        ticket: ticket,
        company_name: data['company_name'],
        address: excavator_address_format(data),
        crew_on_site: data['crew_onsite']
      )
    end

    def ticket_data
      @ticket_data ||= ticket_params.to_h.deep_transform_keys!(&:underscore)
    end

    def ticket_params
      params.permit(
        :RequestNumber,
        :SequenceNumber,
        :RequestType,
        :RequestAction,
        DateTimes: :ResponseDueDateTime,
        ServiceArea: [
          PrimaryServiceAreaCode: :SACode,
          AdditionalServiceAreaCodes: { SACode: [] }
        ],
        ExcavationInfo: [ DigsiteInfo: :WellKnownText ],
        Excavator: %i[CompanyName Address City State Zip CrewOnsite]
      )
    end
  end
end