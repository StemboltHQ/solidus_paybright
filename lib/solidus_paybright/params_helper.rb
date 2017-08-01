module SolidusPaybright
  class ParamsHelper
    include Spree::Core::Engine.routes.url_helpers

    # @param payment [Spree::Payment] The payment in question
    def initialize(payment)
      @payment = payment
    end

    # @return [Hash] The parameters to be used on the Paybright redirect call
    def build_redirect_params
      bill_address = order.bill_address
      ship_address = order.ship_address

      params = {
        # mandatory parameters
        "x_account_id" => credentials[:api_key],
        "x_amount" => order.order_total_after_store_credit.to_money.to_s,
        "x_currency" => order.currency,
        "x_reference" => @payment.id,
        "x_shop_country" => credentials[:shop_country_code],
        "x_shop_name" => credentials[:shop_name],
        "x_test" => credentials[:test_mode].to_s,
        "x_url_callback" => paybright_callback_url,
        "x_url_cancel" => paybright_cancel_url(@payment),
        "x_url_complete" => paybright_complete_url,
        # optional parameters
        "x_description" => "Order ##{order.number}",
        "x_customer_email" => order.email,
        "x_customer_first_name" => bill_address.firstname,
        "x_customer_last_name" => bill_address.lastname,
        "x_customer_billing_address1" => bill_address.address1,
        "x_customer_billing_address2" => bill_address.address2,
        "x_customer_billing_city" => bill_address.city,
        "x_customer_billing_company" => bill_address.company,
        "x_customer_billing_country" => bill_address.country.iso,
        "x_customer_billing_phone" => bill_address.phone,
        "x_customer_billing_state" => bill_address.state.try(:name),
        "x_customer_billing_zip" => bill_address.zipcode,
        "x_customer_shipping_address1" => ship_address.address1,
        "x_customer_shipping_address2" => ship_address.address2,
        "x_customer_shipping_city" => ship_address.city,
        "x_customer_shipping_company" => ship_address.company,
        "x_customer_shipping_country" => ship_address.country.iso,
        "x_customer_shipping_first_name" => ship_address.firstname,
        "x_customer_shipping_last_name" => ship_address.lastname,
        "x_customer_shipping_phone" => ship_address.phone,
        "x_customer_shipping_state" => ship_address.state.try(:name),
        "x_customer_shipping_zip" => ship_address.zipcode
      }

      params.keep_if { |_, value| value.present? }
      params.merge("x_signature" => signing_helper.params_signature(params))
    end

    private

    def order
      @order ||= @payment.order
    end

    def credentials
      @credentials ||= @payment.payment_method.preferences.to_hash
    end

    def signing_helper
      SolidusPaybright::SigningHelper.new(credentials[:api_token])
    end
  end
end
