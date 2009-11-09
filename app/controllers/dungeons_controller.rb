class DungeonsController < ApplicationController
  before_filter :require_user

  def show
    @game = Game.new(current_user)
    @game.run

    @output = @game.look

    respond_to do |format|
      format.js {}
    end

  end


  def update
    @game = Game.new(current_user)
    @game.run

    move = params[:move]

    @output = @game.move(move)

    respond_to do |format|
      format.js {render :action => :show}
    end

  end

end