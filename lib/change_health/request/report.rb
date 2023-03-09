module ChangeHealth
  module Request
    module Claim
      class Report
        ENDPOINT = '/medicalnetwork/reports/v2'.freeze
        HEALTH_CHECK_ENDPOINT = ENDPOINT + '/healthcheck'.freeze

        def self.list(headers: nil)
          ChangeHealth::Response::Claim::ReportListData.new(
            response: ChangeHealth::Connection.new.request(
              endpoint: ENDPOINT,
              verb: :get,
              headers: ChangeHealth::Request::Claim::Report.report_headers(headers)
            )
          )
        end

        def self.retrieve(report_name, json: true, headers: nil)
          return if report_name.empty?

          report_type = ChangeHealth::Response::Claim::ReportData.report_type(report_name)

          return if report_type.nil?

          individual_report_endpoint = "#{ENDPOINT}/#{report_name}"
          individual_report_endpoint += "/#{report_type}" if json # see https://developers.changehealthcare.com/eligibilityandclaims/docs/what-file-types-does-this-api-get-from-the-mailbox

          response = ChangeHealth::Connection.new.request(
            endpoint: individual_report_endpoint,
            verb: :get,
            headers: ChangeHealth::Request::Claim::Report.report_headers(headers)
          )

          if ChangeHealth::Response::Claim::ReportData.is_277?(report_name)
            ChangeHealth::Response::Claim::Report277Data.new(report_name, json, response: response)
          else
            ChangeHealth::Response::Claim::Report835Data.new(report_name, json, response: response)
          end
        end

        def self.delete(report_name, headers: nil)
          ChangeHealth::Connection.new.request(
            endpoint: "#{ENDPOINT}/#{report_name}",
            verb: :delete,
            headers: ChangeHealth::Request::Claim::Report.report_headers(headers)
          )
        end

        def self.health_check
          ChangeHealth::Connection.new.request(endpoint: HEALTH_CHECK_ENDPOINT, verb: :get)
        end

        def self.ping
          self.health_check
        end

        def self.report_headers(headers)
          if headers
            extra_headers = {}
            extra_headers["X-CHC-Reports-Username"] = headers[:username]
            extra_headers["X-CHC-Reports-Password"] = headers[:password]
            extra_headers
          else
            nil
          end
        end
      end
    end
  end
end
