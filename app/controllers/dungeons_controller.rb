class DungeonsController < ApplicationController
  before_filter :require_user

  before_filter :in_game


  def show
    @output = @game.look
  end


  def update
    move = params[:move]
    @output = @game.move(move)
    render :action => :show
  end


end