ActionController::Routing::Routes.draw do |map|

  map.root :controller => "user_sessions", :action => "new" 

  map.resource :user_session

  map.resource :game, :only => [:show] do |game|
    game.resource :dungeon, :only => [:update]
  end

end
