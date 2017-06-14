module SolidusPaybright
  class Configuration < Spree::Preferences::Configuration
    attr_writer :test_redirect_url
    def test_redirect_url
      @test_redirect_url ||= "https://dev.healthsmartfinancial.com/CheckOut/AppForm.aspx"
    end

    attr_writer :live_redirect_url
    def live_redirect_url
      @live_redirect_url ||= "" # TODO
    end
  end
end
