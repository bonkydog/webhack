class DungeonsController < ActionController::Base

  def edit
    @game = Game.find(params[:game_id])
    @game.transcript = "" if @game.transcript.blank?
    @game.transcript += @game.look
    @game.save!
  end

  def update
    @game = Game.find(params[:game_id])
    move = params[:move]
    @game.move(move + "\n")
    redirect_to :action => "edit", :game_id => @game.id
  end

end