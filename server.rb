require 'sinatra'

# Route to / (home page)
get '/' do
  @page = 'blog' # Set page to home (for navigation)
  erb :blog # Render views/home.erb
end

# Route to /{anything here}
get '/:page' do
  @page = params[:page] # Set page to {anything here} (for navigation)
  erb :"#{params[:page]}" # Render views/{anything here}.erb
end

# Route /stylesheets/{anything}.css
get '/stylesheets/:basename.css' do
  file = File.new(File.join(File.dirname(__FILE__), "stylesheets/#{params[:basename]}.scss")) # Put stylesheets/{anything}.scss into a variable
  last_modified file.mtime # Set last_modified header to file's modified time (for caching)
  scss file.read#, :style => :compressed # Compile scss => css in compressed style
end