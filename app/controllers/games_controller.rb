class GamesController < ApplicationController
  before_filter :require_user

  def show
    @game = Game.find_by_user_id(current_user.id)
    unless @game
      @game = Game.new(:user_id => current_user.id)
      @game.start
      @game.save!
    end
  end
  
end
