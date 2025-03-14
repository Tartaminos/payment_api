module Gateways
    class PaymentGatewayService

        def initialize(payment_transaction)
            @payment_transaction = payment_transaction
        end

        def process_transaction(payment_transaction)

            transaction_approval_service = Payments::TransactionApprovalService.new(payment_transaction)

            if transaction_approval_service.is_rejected(payment_transaction)
               return reject_transaction()
            end

            approve_transaction()

        end

        def approve_transaction()
            payment_transaction_service = Payments::PaymentTransactionService.new()
            payment_transaction_service.update_transaction({status: 'aprovado'}, @payment_transaction)
      
            repassed_amount = retention_calc(@payment_transaction)

            amount_per_receivable = amount_per_receivable_calc(repassed_amount, @payment_transaction)
      
            schedule_receivable(amount_per_receivable)
      
            { success: true, message: "Transação aprovada e em processamento." }
        end

        def reject_transaction()
            payment_transaction_service = Payments::PaymentTransactionService.new()
            payment_transaction_service.update_transaction({status: 'reprovado'}, @payment_transaction)

            { success: false, message: "Transação reprovada: número de parcelas ímpar." }
        end

        def retention_calc(payment_transaction)
            fee_service = Fees::InstallmentFeesService.new(@payment_transaction.installment)
            fee_percentage = fee_service.installment_fee_percentage(@payment_transaction.installment)

            fee_service.retention_calculation(@payment_transaction, fee_percentage)
        end

        def amount_per_receivable_calc(repassed_amount, payment_transaction)
            repassed_amount / @payment_transaction.installment
        end

        def schedule_receivable(amount_per_receivable)
            Receivables::ReceivableSchedulerService.new().schedule(@payment_transaction, amount_per_receivable)
        end
    end
end
