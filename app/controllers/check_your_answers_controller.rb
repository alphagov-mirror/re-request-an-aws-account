class CheckYourAnswersController < ApplicationController
  def check_your_answers
    @answers = session.fetch('form', {}).with_indifferent_access
  end

  def post
    @details_form = AccountDetailsForm.new(session.fetch('form', {}))

    all_params = session['form']

    account_name = all_params['account_name']
    account_description = all_params['account_description']
    programme_or_other = all_params['programme_or_other']
    admin_users = all_params['admin_users']
    email = session['email']

    pull_request_url = GithubService.new.create_new_account_pull_request(
      account_name,
      account_description,
      programme_or_other,
      email,
      admin_users
    )

    if pull_request_url then
      session['pull_request_url'] = pull_request_url

      notify_service = NotifyService.new
      notify_service.new_account_email_support(
        account_name: account_name,
        account_description: account_description,
        programme: programme_or_other,
        email: email,
        pull_request_url: pull_request_url,
        admin_users: admin_users
      )
      notify_service.new_account_email_user email, account_name, pull_request_url

      redirect_to confirmation_account_path
    else
      @form.errors.add 'account_name', 'account already exists'
      return render :user
    end
  end
end