class GamesController < ApplicationController
  before_filter :require_user

  def show
    @game = Game.new(current_user)
    @reload = ! flash[:new_game]
    unless @game.running?
      logger.info "Game over on show.  Redirecting #{current_user.login} to login page."
      redirect_to new_user_session_url
    end
  end
  
end

