class ApplicationController < ActionController::Base
  # :null_session better for microservice api 
  protect_from_forgery with: :null_session
end
