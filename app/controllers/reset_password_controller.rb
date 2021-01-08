class ResetPasswordController < ApplicationController
  def reset_password
    @form = UserForm.new({})
  end

  def post
    form_params = params
                    .fetch('reset_form', {})
    @form = UserForm.new(form_params)

    requester_name = session.fetch('name')
    requester_email = session.fetch('email')

    pull_request_url = GithubService.new.create_reset_user_email_pull_request(requester_name, requester_email)

    if pull_request_url then
      session['pull_request_url'] = pull_request_url

      notify_service = NotifyService.new
      notify_service.reset_password_email_support(requester_name, requester_email, pull_request_url)
      notify_service.reset_password_email_user(requester_name, requester_email, pull_request_url)

      redirect_to confirmation_reset_password_path
    else
      @form.errors.add 'commit', 'your user does not exist'
      return render :reset_password
    end
  end
end
