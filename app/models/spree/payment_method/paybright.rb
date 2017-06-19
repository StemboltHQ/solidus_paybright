module Spree
  class PaymentMethod::Paybright < Spree::PaymentMethod
    preference :api_key, :string
    preference :api_token, :string
    preference :shop_country_code, :string
    preference :shop_name, :string
    preference :test_mode, :boolean, default: true

    def payment_source_class
      nil
    end

    def source_required?
      false
    end

    def auto_capture
      false
    end

    def redirect_url(payment)
      uri = URI.parse(paybright_redirect_url)
      params = SolidusPaybright::ParamsHelper.new(payment).build_redirect_params
      uri.query = params.to_query

      uri.to_s
    end

    private

    def paybright_redirect_url
      if preferred_test_mode
        SolidusPaybright::Config.test_redirect_url
      else
        SolidusPaybright::Config.live_redirect_url
      end
    end
  end
end
