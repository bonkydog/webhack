class DungeonsController < ActionController::Base

  def update
    @game = Game.find(params[:game_id])

    move = params[:move]

    # move = "\n" if move == "" # for nethack
    move = "#{move}\n" # for wumpus

    @output = @game.move_and_look(move)

    @game.transcript = "" if @game.transcript.blank?
    @game.transcript += @output
    @game.save!

    respond_to do |format|
      format.html { redirect_to @game }
      format.js {} 
    end

  end


end