class UserSessionsController < ApplicationController
  before_filter :require_user, :only => :destroy

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      Game.new(@user_session.user).start

      flash[:new_game] = true
      redirect_to game_url
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    redirect_to "/"
  end
end