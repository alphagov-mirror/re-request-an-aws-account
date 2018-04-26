class AccountDetailsController < ApplicationController
  def account_details
    @form = AccountDetailsForm.new(session.fetch('form', {}))
  end

  def post
    form_params = params
      .fetch('account_details_form', {})
      .permit(:account_name, :is_production).to_h
    @form = AccountDetailsForm.new(form_params)
    return render :account_details if @form.invalid?

    session['form'] = session.fetch('form', {}).merge form_params
    redirect_to programme_path
  end
end