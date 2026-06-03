class GamesController < ApplicationController
  def search
    games = Game
              .where("name ILIKE ?", "#{params[:q]}%")
              .order(:name)
              .limit(10)
    
    authorize Game, :search?
    
    render json: games.select(:id, :name)
  end
end
