class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by email: params[:email]

    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.update activated: true, activated_at: Time.zone.now
      log_in user
      flash[:success] = t "account_activations_controller.acc_active"
      redirect_to user
    else
      flash[:danger] = t "account_activations_controller.in_act_link"
      redirect_to root_url
    end
  end
end
