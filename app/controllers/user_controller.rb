class UserController < ApplicationController
  def user
    @form = UserForm.new({})
  end

  def post
    form_params = params
                    .fetch('user_form', {})
                    .permit(:email_list).to_h
    @form = UserForm.new(form_params)
    return render :user if @form.invalid?

    requester_email = session.fetch('email')
    email_list = @form.email_list

    pull_request_url = GithubService.new.create_new_user_pull_request(email_list, requester_email)

    if pull_request_url then
      session['pull_request_url'] = pull_request_url

      notify_service = NotifyService.new
      notify_service.new_user_email_support(email_list, requester_email, pull_request_url)
      notify_service.new_user_email_user(email_list, requester_email, pull_request_url)

      redirect_to confirmation_user_path
    else
      @form.errors.add 'email_list', 'contains already-existing user'
      return render :user
    end
  end
end