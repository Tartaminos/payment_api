class PaymentTransactionsController < ApplicationController

    def create
      transaction_service = Payments::PaymentTransactionService.new(transaction_params)
      transaction = transaction_service.create_transaction(transaction_params)
  
      if transaction.save
        gateway_service = Gateways::PaymentGatewayService.new(transaction)

        result = gateway_service.process_transaction(transaction)
  
        render json: {
          transaction_id: transaction.id,
          status: transaction.status,
          message: result[:message]
        }, status: :created
      else
        render json: { errors: transaction.errors.messages },
               status: :unprocessable_entity
      end
    end
  
    def index
      start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago.to_date
      end_date = params[:end_date]   ? Date.parse(params[:end_date]) : Date.current
  
      transaction_service = Payments::PaymentTransactionService.new
      transactions = transaction_service.load_transaction_by_date_range(start_date, end_date)
  
      page = params[:page].to_i.positive? ? params[:page].to_i : 1
      per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 30

      transactions = paginate_transactions(page, per_page, transactions)
  
      render json: transactions.as_json(only: [:id, :installment, :status])
    end
  
    private
  
    def transaction_params
      params.require(:transaction).permit(:amount, :installment, :payment_method)
    end

    def paginate_transactions(page, per_page, transactions)
        transactions.offset((page - 1) * per_page).limit(per_page)
    end
end
  