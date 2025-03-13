class Receivable < ApplicationRecord
	belongs_to :payment_transaction

	scope :approved, lambda {
		joins(:payment_transaction).where(payment_transactions: { status: 'aprovado' })
	}

	scope :pending_today, lambda {
		where(schedule_date: Date.current, status: 'pendente')
	}

	scope :all_receivables, lambda {
		joins(:payment_transaction)
	}

	def self.liquidate_receivable(receivables_to_liquidate, date)
		receivables_to_liquidate.find_each do |receivable|
			receivable.update!(
			  status: 'liquidado',
			  liquidation_date: date,
			  amount_settled: receivable.amount_to_settle
			)
		end
	end


	def self.create_receivable(transaction, amount_per_receivable)
		transaction.installment.times do |installment|
            Receivable.create!(
                payment_transaction_id: transaction.id,
                installment: installment + 1,
                schedule_date: schedule_date(transaction, installment),
                status: 'pendente',
                amount_to_settle: amount_per_receivable,
                amount_settled: 0
            )
        end
	end

	def self.schedule_date(transaction, installment)
		transaction.created_at + (installment + 1).months
	end
end
