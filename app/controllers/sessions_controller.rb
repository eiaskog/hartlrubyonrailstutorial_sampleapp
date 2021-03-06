class SessionsController < ApplicationController

  def new
  end

  def create
    # Defines the user
    @user = User.find_by(email: params[:session][:email].downcase)
    # Check so that @user exists and that the password is valid
    if @user && @user.authenticate(params[:session][:password])
      # Check if user is activated
      if @user.activated?
        # Log in user, log_in -> app/helpers/sessions_helper.rb
        log_in @user
        # Check if the rememeber me checkbox is checked
        # Remember(), forget() -> app/helpers/sessions_helper.rbm
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        # Redirect to user page (show template)
        redirect_back_or @user
      else
        # Variable containg string
        message = "This account has not been activated yet. "
        # Concatenate the variable with this string
        message += 'Check your email for the activation link.'
        # Show string as a warning
        flash[:warning] = message.html_safe
        # Redirect to home page
        redirect_to root_url
      end
    else
      # Show error message
      flash.now[:danger] = 'Invalid email/password combination'
      # Render new page again
      render 'new'
    end
  end

  def destroy
    # Log out user is user is logged in, app/helpers/sessions_helper.rb
    log_out if logged_in?
    # Redirect to home page
    redirect_to root_url
  end

end
