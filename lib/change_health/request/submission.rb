module ChangeHealth
  module Request
    module Claim
      class Submission < Hashie::Trash
        
        ENDPOINT = '/medicalnetwork/professionalclaims/v3'.freeze
        HEALTH_CHECK_ENDPOINT = ENDPOINT + '/healthcheck'.freeze
        SUBMISSION_ENDPOINT = ENDPOINT + '/submission'.freeze
        VALIDATION_ENDPOINT = ENDPOINT + '/validation'.freeze

        property :claimInformation, from: :claim_information, required: false
        property :controlNumber, from: :control_number, required: true, default: ChangeHealth::Models::CONTROL_NUMBER
        property :providers, required: false
        property :receiver, required: false
        property :submitter, required: false
        property :subscriber, required: false
        property :headers, required: false
        # Need one or the other, trading partner id or trading partner service id
        property :tradingPartnerId, from: :trading_partner_id, required: false
        property :tradingPartnerServiceId, from: :trading_partner_service_id, required: false

        def add_provider(provider)
          self[:providers] ||= []
          self[:providers] << provider
        end

        def submission
          ChangeHealth::Response::Claim::SubmissionData.new(response: ChangeHealth::Connection.new.request(endpoint: SUBMISSION_ENDPOINT, body: self.to_h, headers: professional_headers))
        end

        def validation
          ChangeHealth::Response::Claim::SubmissionData.new(response: ChangeHealth::Connection.new.request(endpoint: VALIDATION_ENDPOINT, body: self.to_h, headers: professional_headers))
        end

        def self.health_check(headers)
          headers = ChangeHealth::Request::Claim::Submission.new(headers: headers).professional_headers
          ChangeHealth::Connection.new.request(endpoint: HEALTH_CHECK_ENDPOINT, verb: :get, headers: headers)
        end

        def self.ping
          self.health_check
        end

        def professional_headers
          extra_headers = {}
          extra_headers["X-CHC-ClaimSubmission-SubmitterId"] = self[:headers][:submitter_id]
          extra_headers["X-CHC-ClaimSubmission-BillerId"] = self[:headers][:biller_id]
          extra_headers["X-CHC-ClaimSubmission-Username"] = self[:headers][:username]
          extra_headers["X-CHC-ClaimSubmission-Pwd"] = self[:headers][:password]
          extra_headers
        end

        private

        def access_header
          return {
            'Authorization' => "Bearer #{self.access_token}",
          }
        end
      end
    end
  end
end
