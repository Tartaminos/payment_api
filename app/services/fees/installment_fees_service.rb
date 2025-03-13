module Fees
    class InstallmentFeesService
        def initialize(installment)
          @installment = installment
        end

        def installment_fee_percentage(installment)
            InstallmentFee.installment_fee_percentage(installment).to_f
        end

        def retention_calculation(payment_transaction, fee_percentage)
            total_retention_rate = fee_percentage / 100.0

            total_retention = payment_transaction.amount * total_retention_rate

            payment_transaction.amount - total_retention
        end
    end
end