class LandingsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  layout 'landing', only: [:index]

  def index
    @qr_google_play = RQRCode::QRCode.new(Rails.application.secrets.qrcode_google_play)
    @qr_app_store = RQRCode::QRCode.new(Rails.application.secrets.qrcode_app_store)
  end
end
