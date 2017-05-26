class TwoFactorAuthorizationController < ApplicationController
  def enable
    current_user.update(two_factor: true)
    redirect_to :back
  end

  def disable
    current_user.update(two_factor: false)
    redirect_to :back
  end
end