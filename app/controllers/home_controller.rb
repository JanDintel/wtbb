class HomeController < ApplicationController
  def index
    redirect_to events_path if current_user
  end
end