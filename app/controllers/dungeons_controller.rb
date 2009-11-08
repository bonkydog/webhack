class DungeonsController < ApplicationController
  before_filter :require_user

  def update
    @game = Game.find_by_user_id(current_user.id)

    move = params[:move]

    @output = @game.move_and_look(move)

    respond_to do |format|
      format.js {}
    end

  end

end