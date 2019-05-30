# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  post "/paybright/callback", to: "paybright#callback", as: :paybright_callback
  get "/paybright/cancel/:payment_id", to: "paybright#cancel", as: :paybright_cancel
  get "/paybright/complete", to: "paybright#complete", as: :paybright_complete
end
