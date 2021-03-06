class UsersController < ApplicationController

  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  # app/views/users/new.html.erb
  def new
    # Defines @user to be used in new template
    @user = User.new
  end

  # app/views/users/show.html.erb
  def show
    # Creates a user variable to be used in the show template
    @user = User.find(params[:id])
    # paginate microposts
    @microposts = @user.microposts.paginate(page: params[:page])
    redirect_to root_url and return unless @user.activated?
  end

  def create
    # Redefined the @user, now with the info filled in the form
    @user = User.new(user_params)
    # If user is savable (valid)
    if @user.save
      # Send activation mail, send_activation_email -> app/models/user.rb
      @user.send_activation_email
      # Show message
      flash[:info] = 'Please check your email to active your account'
      # Go back to homepage
      redirect_to root_url
    # If user is not savable (invalid)
    else
      # Render signup page again (new template)
      render 'new'
    end
  end

  def edit
    # Get the user
    @user = User.find(params[:id])
  end

  def update
    # Get the user
    @user = User.find(params[:id])
    # If user is updatable
    if @user.update_attributes(user_params)
      # Something
      flash[:success] = "Your profile has been updated"
      redirect_to @user
    else
      # Render the edit page again
      render 'edit'
    end
  end

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def destroy
    flash[:success] = "The user #{User.find(params[:id]).name} has been deleted"
    User.find(params[:id]).destroy
    redirect_to users_path
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Follower"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  # Question: Why is private flooting by itself? Why no ending?
  private
    # Definges the parameters needed to create a user
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def correct_user
      # Find user by id
      @user = User.find(params[:id])
      # Redirect home unless users match
      redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      # Go to homepate unless current user is not admin
      redirect_to(root_url) unless current_user.admin?
    end

end
