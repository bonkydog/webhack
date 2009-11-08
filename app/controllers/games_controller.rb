class GamesController < ApplicationController
  before_filter :require_user


  # GET /games/1
  def show
    @game = Game.find(params[:id])
  end
  
  # GET /games/new
  def new
    @game = Game.new
  end

  # POST /games
  def create
    @game = Game.new(params[:game])
    @game.start
    if @game.save
      redirect_to :action => "show", :id => @game.id
    else
      render :action => "new"
    end
  end

end
