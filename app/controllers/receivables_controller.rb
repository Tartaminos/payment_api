class ReceivablesController < ApplicationController

	def index
		receivable_service = Receivables::ReceivablesService.new()

		approved_only = ActiveRecord::Type::Boolean.new.cast(params[:approved_only])

		if approved_only
		  receivables = receivable_service.load_approved_receivables()
		else
		  receivables = receivable_service.load_all_receivables()
		end

		render json: receivables.as_json(
			only: [
				:payment_transaction_id,
				:installment,
				:schedule_date,
				:liquidation_date,
				:status,
				:amount_to_settle,
				:amount_settled
			]
		), status: :ok
	end
end
  