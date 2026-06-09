class FavouritesController < ApplicationController
  before_action :authenticate_user!

  def create
    skip_authorization
    post = Post.find(params[:post_id])
    current_user.favourites.find_or_create_by(post: post)
    redirect_back(fallback_location: my_matches_path)
  end

  def destroy
    skip_authorization
    post = Post.find(params[:post_id])
    current_user.favourites.find_by(post: post)&.destroy
    redirect_back(fallback_location: my_matches_path)
  end
end
