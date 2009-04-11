# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  helper :all # include all helpers, all the time
  filter_parameter_logging :password #prevent logging of password param
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'e3a2381ed3c0a1d9a991691d41eb753b'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  def index
    
  end

#do not log routing errors, unknown actions
#this keeps the log file size from growing unnecessarily
#EXCEPTIONS_NOT_LOGGED = ['ActionController::UnknownAction',
#                         'ActionController::RoutingError']
#protected
#  def log_error(exc)
#    super unless EXCEPTIONS_NOT_LOGGED.include?(exc.class.name)
#  end

end
