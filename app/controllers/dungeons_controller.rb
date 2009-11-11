class DungeonsController < ApplicationController
  before_filter :require_user

  # SPIKE experimental
  def show
    @game = Game.new(current_user)
    if @game.running?

      @output = @game.look

      respond_to do |format|
        format.js {}
      end

    else
      render :text => "location = '/';"
    end
  end


  def update
    @game = Game.new(current_user)

    if @game.running?

      move = params[:move]

      @output = @game.move(move)

      respond_to do |format|
        format.js {render :action => :show}
      end

    else
      render :text => "location = '/';"
    end
  end

end