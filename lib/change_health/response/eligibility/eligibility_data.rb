require 'forwardable'

module ChangeHealth
  module Response
    class EligibilityData < ChangeHealth::Response::ResponseData
      extend Forwardable

      ACTIVE = '1'
      INACTIVE = '6'

      def_delegators :raw, :dig

      def active?(service_code: '30')
        plan_status(service_code: service_code, single: false).any? {|status| ACTIVE == status['statusCode'] }
      end

      def inactive?(service_code: '30')
        plan_status(service_code: service_code, single: false).any? {|status| INACTIVE == status['statusCode'] }
      end

      def dependents?
        true == self.dependents&.any?
      end

      %w(planStatus benefitsInformation controlNumber planDateInformation dependents subscriber).each do |v|
        define_method(v) do
          @raw.dig(v)
        end
      end

      %w(eligibilityBegin planBegin service).each do |f|
        define_method(f) do
          return ChangeHealth::Models::PARSE_DATE.call(self.date_info&.dig(f))
        end
      end
      alias_method :eligibility_begin_date, :eligibilityBegin
      alias_method :plan_begin_date, :planBegin
      alias_method :service_date, :service

      def plan_date_range
        plan_date = self.date_info&.dig("plan")
        plan_date ||= self.date_info["planBegin"] if self.date_info.present? && self.date_info["planBegin"].to_s =~ /-/
        (plan_date || "").split('-')
      end

      def plan_date_range_start
        ChangeHealth::Models::PARSE_DATE.call(self.plan_date_range[0])
      end

      def plan_date_range_end
        ChangeHealth::Models::PARSE_DATE.call(self.plan_date_range[1])
      end

      def plan_status(service_code: , single: true)
        if true == single
          self.planStatus&.find {|plan| plan.dig('serviceTypeCodes')&.include?(service_code) } || {}
        else
          self.planStatus&.select {|plan| plan.dig('serviceTypeCodes')&.include?(service_code) } || []
        end
      end

      def benefits
        kname   = "ChangeHealth::Response::EligibilityBenefits#{self.trading_partner_id&.upcase}"
        klazz   = Object.const_get(kname) if Module.const_defined?(kname)
        klazz ||= ChangeHealth::Response::EligibilityBenefits

        if klazz.respond_to?(:factory)
          klazz = klazz.factory(self)
        end

        klazz.new(self.benefitsInformation || [])
      end

      def medicare?(**kwargs)
        false == benefits.empty? && benefits.where(kwargs).all? {|b| b.medicare? }
      end

      def plan?(name)
        self.plan_names.any? {|pname| name == pname }
      end

      def plan_names
        self.planStatus&.map {|plan_status| plan_status['planDetails'] }&.compact || []
      end

      def trading_partner?(name)
        self.trading_partner_id == name
      end

      def trading_partner_id
        @raw['tradingPartnerServiceId']
      end

      alias_method :control_number, :controlNumber
      alias_method :benefits_information, :benefitsInformation
      alias_method :plan_statuses, :planStatus
      alias_method :date_info, :planDateInformation
    end
  end
end
