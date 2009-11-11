class GamesController < ApplicationController
  before_filter :require_user

  def show
    @game = Game.new(current_user)
    redirect_to new_user_session_url unless @game.running?
  end
  
end
