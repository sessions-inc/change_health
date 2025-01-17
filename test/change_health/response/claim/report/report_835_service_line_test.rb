require 'test_helper'

class Report835ServiceLineTest < Minitest::Test
   describe 'line_adjudication_information' do
      let(:service_adjustments) do
         ChangeHealth::Response::Claim::Report835ServiceAdjustment.new(
         adjustments: { "45" => "180.82", "253" => "13.24", "59" => "827.59" },
         claim_adjustment_group_code: "PR"
         )
      end
      let(:service_adjustments_2) do
         ChangeHealth::Response::Claim::Report835ServiceAdjustment.new(
         adjustments: { "2" => "165.52" },
         claim_adjustment_group_code: "CO"
         )
      end

      let(:claim_information) do
         ChangeHealth::Response::Claim::Report835ServiceLine.new(adjudicated_procedure_code: 'J1745', allowed_actual: 30_720.0, line_item_charge_amount: 48_000.0, line_item_provider_payment_amount: '18432', service_adjustments: [service_adjustments, service_adjustments_2],
         health_care_check_remark_codes: [])
      end

      it 'creates adjustments correctly when there are multiple adjustments in a group code' do
         expected_answer = [
            {
               adjustmentDetails: [
               {
                  adjustmentReasonCode: "45",
                  adjustmentAmount: "180.82"
               },
               {
                  adjustmentReasonCode: "253",
                  adjustmentAmount: "13.24"
               },
               {
                  adjustmentReasonCode: "59", adjustmentAmount: "827.59"
               }
               ],
               adjustmentGroupCode: "PR"
            },
            {
               adjustmentDetails: [
               {
                  adjustmentReasonCode: "2",
                  adjustmentAmount: "165.52"
               }
               ],
               adjustmentGroupCode: "CO"
            }
         ]

         actual_result = claim_information.create_adjustment_detail_array
         assert_equal(expected_answer, actual_result)
      end
   end
end