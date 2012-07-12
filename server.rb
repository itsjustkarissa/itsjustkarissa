require 'sinatra'
require 'yaml'

def file_relative(path)
  File.new(File.join(File.dirname(__FILE__), path))
end

# Route to / (home page)
get '/' do
  @page = 'home' # Set page to home (for navigation)
  erb :home # Render views/home.erb
end

get '/recipes' do
  @page = 'recipes'
  recipe_files = YAML::load(file_relative('views/recipes/_published.yaml'))
  @recipes = []
  recipe_files.reverse.each do |recipe_file|
    recipe_yaml = YAML::load(file_relative("views/recipes/#{recipe_file}.yaml").read)
    @recipes.push({
      :path => recipe_file,
      :image => recipe_yaml["image"].sub('.', '-sample.'),
      :title => recipe_yaml["title"]
    })
  end
  erb :recipes
end

# Route to /{anything here}
get '/:page' do
  @page = params[:page] # Set page to {anything here} (for navigation)
  erb :"#{params[:page]}" # Render views/{anything here}.erb
end

get '/recipes/:recipe' do
  @page = 'recipes'
  @contents = YAML::load(file_relative("views/recipes/#{params[:recipe]}.yaml").read)
  erb :recipe
end
  
# Route /stylesheets/{anything}.css
get '/stylesheets/:basename.css' do
  file = file_relative "stylesheets/#{params[:basename]}.scss" # Put stylesheets/{anything}.scss into a variable
  last_modified file.mtime # Set last_modified header to file's modified time (for caching)
  scss file.read#, :style => :compressed # Compile scss => css in compressed style
end