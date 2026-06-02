class PagesController < ApplicationController
  def home
    @posts = Post.includes(:user).order(created_at: :desc).limit(6)
  end
end
