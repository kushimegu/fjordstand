class PagesController < ApplicationController
  skip_before_action :check_logged_in
  def home
  end

  def terms
  end

  def privacy
  end
end
