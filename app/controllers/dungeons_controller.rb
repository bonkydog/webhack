class DungeonsController < ActionController::Base

  def update
    @game = Game.find(params[:game_id])

    move = params[:move]

    # move = "\n" if move == ""
    move = "#{move}\n"

    output = @game.move_and_look(move)

    @game.transcript = "" if @game.transcript.blank?
    @game.transcript += output
    @game.save!

    render :juggernaut do |page|
      page.insert_html :bottom, 'transcript', output
      page.visual_effect :scroll_to, "move" 
    end

    render :nothing => true
  end


end