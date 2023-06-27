# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::TicketsController, type: :controller do
  describe 'POST #create' do
    let(:json_response) { JSON.parse(response.body) }
    let(:response_due_date_time) { Time.now }
    let(:request_number) { '09252012-00001' }
    let(:sequence_number) { '2421' }
    let(:request_type) { 'Normal' }
    let(:request_action) { 'Restake' }

    let(:primary_service_area_code) { 'ZZGL103' }
    let(:additional_service_area_codes) { %w[ZZL01 ZZL02 ZZL03] }
    let(:company_name) { 'John Doe CONSTRUCTION' }
    let(:address) { '555 Some RD' }
    let(:city) { 'SOME PARK' }
    let(:state) { 'ZZ' }
    let(:zip) { '55555' }
    let(:crew_on_site) { 'true' }

    let(:well_known_text) do
      'POLYGON((-81.13390268058475     32.07206917625161,   -81.14660562247929 32.04064386441295,-81.08858407706913 32.02259853170128,-81.05322183341679 32.02434500961698,-81.05047525138554 32.042681017283066,-81.0319358226746 32.06537765335268,-81.01202310294804 32.078469305179404,-81.02850259513554 32.07963291684719,-81.07759774894413   32.07090546831167,   -81.12154306144413 32.08806865844325, -81.13390268058475 32.07206917625161))'
    end

    let(:request_body) do
      {
        RequestNumber: request_number,
        SequenceNumber: sequence_number,
        RequestType: request_type,
        RequestAction: request_action,
        DateTimes: { ResponseDueDateTime: response_due_date_time },
        ServiceArea: {
          PrimaryServiceAreaCode: { SACode: primary_service_area_code },
          AdditionalServiceAreaCodes: { SACode: additional_service_area_codes }
        },
        ExcavationInfo: {
          DigsiteInfo: { WellKnownText: well_known_text }
        },
        Excavator: {
          CompanyName: company_name,
          Address: address,
          City: city,
          State: state,
          Zip: zip,
          CrewOnsite: crew_on_site
        }
      }
    end

    describe 'excavator creation' do
      before do
        post :create, params: request_body
      end

      context 'when excavator address data is invalid' do
        let(:address) { nil }
        let(:city) { nil }
        let(:state) { nil }
        let(:zip) { nil }

        it 'returns unprocessable_entity status and errors' do
          expect(response).to have_http_status(:unprocessable_entity)

          expect(json_response['errors']).to match_array(['Address is required', 'City key is required',
                                                          'State key is required', 'Zip key is required'])
        end

        it 'should not create a new excavator and rollback ticket creation' do
          expect(Ticket.count).to eq(0)
          expect(Excavator.count).to eq(0)
        end
      end

      context 'when excavator data is invalid' do
        let(:company_name) { nil }
        let(:crew_on_site) { nil }

        it 'returns unprocessable_entity status and errors' do
          expect(response).to have_http_status(:unprocessable_entity)

          expect(json_response['errors']).to match_array(['Company name can\'t be blank',
                                                          'Crew on site can\'t be blank'])
        end

        it 'does not create a new excavator and rollback ticket creation' do
          expect(Ticket.count).to eq(0)
          expect(Excavator.count).to eq(0)
        end
      end
    end

    describe 'ticket creation' do
      context 'when post ticket with valid params' do
        it 'creates a new Ticket' do
          expect do
            post :create, params: request_body
          end.to change(Ticket, :count).by(1)
        end

        it 'creates a new Excavator' do
          expect do
            post :create, params: request_body
          end.to change(Excavator, :count).by(1)
        end

        it 'renders a JSON response with the new ticket' do
          post :create, params: request_body
          expect(response).to have_http_status(:created)
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
      end

      context 'when the RequestNumber is not unique' do
        before do
          post :create, params: request_body
          post :create, params: request_body
        end

        it 'returns unprocessable_entity status and errors' do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['errors']).to include('Request number has already been taken')
        end

        it 'does not create a new ticket or excavator' do
          expect(Ticket.count).to eq(1)
          expect(Excavator.count).to eq(1)
        end
      end

      context 'when posting a ticket with invalid params' do
        let(:request_number) { nil }
        let(:request_type) { nil }
        let(:request_action) { nil }
        let(:response_due_date_time) { nil }
        let(:primary_service_area_code) { nil }
        let(:additional_service_area_codes) { nil }
        let(:digsite_info_well_known_text) { nil }

        before do
          post :create, params: request_body
        end

        it 'returns unprocessable_entity status and errors' do
          expect(response).to have_http_status(:unprocessable_entity)

          expect(json_response['errors'])
            .to match_array(
              [
                'Request number can\'t be blank',
                'Request type can\'t be blank',
                'Request action can\'t be blank',
                'Response due date time can\'t be blank',
                'Primary service area code can\'t be blank',
                'Additional service area codes can\'t be blank'
              ]
            )
        end

        it 'does not create a new excavator and rollback ticket creation' do
          expect(Ticket.count).to eq(0)
          expect(Excavator.count).to eq(0)
        end
      end
    end
  end
end
