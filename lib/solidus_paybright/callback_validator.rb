module SolidusPaybright
  class CallbackValidator
    # @param params [Hash] The Paybright callback params
    def initialize(params)
      @params = params
    end

    # @return [Array] The validation result and the error message
    def call
      payment = Spree::Payment.find_by(id: @params[:x_reference])

      unless payment
        return [false, "Payment #{@params[:x_reference]} not found"]
      end

      if payment.completed?
        return [false, "Payment #{payment.id} is already in completed state"]
      end

      if payment.order.complete?
        return [false, "Order is already in complete state"]
      end

      if !signing_helper(payment).valid_params?(@params.to_hash)
        return [false, "Invalid parameters signature"]
      end

      if @params[:x_result].casecmp("completed") != 0
        return [false, "The contract was not completed (#{@params[:x_result]})"]
      end

      [true, ""]
    end

    private

    def signing_helper(payment)
      api_token = payment.payment_method.preferences.fetch(:api_token)
      SolidusPaybright::SigningHelper.new(api_token)
    end
  end
end
