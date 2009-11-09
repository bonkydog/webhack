class GamesController < ApplicationController
  before_filter :require_user

  def show
    @game = Game.new(current_user)
    @game.run
  end
  
end
