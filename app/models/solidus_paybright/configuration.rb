# frozen_string_literal: true

module SolidusPaybright
  class Configuration < Spree::Preferences::Configuration
    attr_writer :test_redirect_url
    def test_redirect_url
      @test_redirect_url ||= "https://sandbox.paybright.com/CheckOut/AppForm.aspx"
    end

    attr_writer :live_redirect_url
    def live_redirect_url
      @live_redirect_url ||= "https://app.paybright.com/checkout/appform.aspx"
    end

    attr_writer :test_api_endpoint
    def test_api_endpoint
      # no trailing slash
      @test_api_endpoint ||= "https://sandbox.api.paybright.com/api"
    end

    attr_writer :live_api_endpoint
    def live_api_endpoint
      # no trailing slash
      @live_api_endpoint ||= "https://api.paybright.com/api"
    end
  end
end
