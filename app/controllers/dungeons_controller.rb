class DungeonsController < ApplicationController

  def update
    @game = Game.find(params[:game_id])

    move = params[:move]

    @output = @game.move_and_look(move)

    respond_to do |format|
      format.js {}
    end

  end

end