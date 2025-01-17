module ChangeHealth
  module Models
    module Claim
      class Subscriber < Model
        property :address, required: false
        property :dateOfBirth, from: :date_of_birth, required: false
        property :firstName, from: :first_name, required: false
        property :gender, required: false
        property :groupNumber, from: :group_number, required: false
        property :insuranceTypeCode, from: :insurance_type_code, required: false
        property :lastName, from: :last_name, required: false
        property :memberId, from: :member_id, required: false
        property :paymentResponsibilityLevelCode, from: :payment_responsibility_level_code, required: false
        property :subscriberGroupName, from: :subscriber_group_name, required: false
      end
    end
  end
end
