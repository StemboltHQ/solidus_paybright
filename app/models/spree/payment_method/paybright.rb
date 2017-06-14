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
  end
end
