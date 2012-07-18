require 'sinatra'
require 'yaml'
require 'sass'

def file_relative(path)
  file = File.join(File.dirname(__FILE__), path)
  if File.exists?(file)
    File.new(file)
  else
    not_found
  end
end

not_found do
  status 404
  erb :'404', :layout => false
end

# Route to / (home page)
get '/' do
  @page = 'home' # Set page to home (for navigation)
  erb :home # Render views/home.erb
end

get '/shop' do
  @page = 'shop'
  shop_files = YAML::load(file_relative('views/shop/_published.yaml'))
  @shop_items = []
  shop_files.reverse.each do |shop_file|
    shop_yaml = YAML::load(file_relative("views/shop/#{shop_file}.yaml").read)
    @shop_items.push({
      :path => shop_file,
      :image => shop_yaml["image"].sub('.', '-sample.'),
      :title => shop_yaml["title"]
    })
  end
  erb :'shop/shop_items'
end

get '/shop/:shop_item' do
  @page = 'shop'
  shop_files = YAML::load(file_relative('views/shop/_published.yaml'))
  if shop_files.include?(params[:shop_item])
    @contents = YAML::load(file_relative("views/shop/#{params[:shop_item]}.yaml").read)
    erb :'shop/shop_item'
  else
    not_found
  end
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
  erb :'recipes/recipes'
end

get '/recipes/:recipe' do
  @page = 'recipes'
  recipe_files = YAML::load(file_relative('views/recipes/_published.yaml'))
  if recipe_files.include?(params[:recipe])
    @contents = YAML::load(file_relative("views/recipes/#{params[:recipe]}.yaml").read)
    erb :'recipes/recipe'
  else
    not_found
  end
end

get '/blog' do
  @page = 'blog'
  blog_files = YAML::load(file_relative('views/blog/_published.yaml'))
  @blog_posts = []
  blog_files.reverse.each do |blog_file|
    blog_yaml = YAML::load(file_relative("views/blog/#{blog_file}.yaml").read)
    @blog_posts.push({
      :path => blog_file,
      :title => blog_yaml["title"],
      :date => blog_yaml["date"],
      :content => blog_yaml["content"]
    })
  end
  erb :'blog/blog_posts'
end

get '/blog/:blog_post' do
  @page = 'blog'
  blog_files = YAML::load(file_relative('views/blog/_published.yaml'))
  if blog_files.include?(params[:blog_post])
    @blog_post = YAML::load(file_relative("views/blog/#{params[:blog_post]}.yaml").read)
    erb :'blog/blog_post'
  else
    not_found
  end
end

# Route to /{anything here}
get '/:page' do
  if File.exists?(file_relative("views/#{params[:page]}.erb"))
    @page = params[:page] # Set page to {anything here} (for navigation)
    erb :"#{params[:page]}" # Render views/{anything here}.erb
  else
    not_found
  end
end
  
# Route /stylesheets/{anything}.css
get '/stylesheets/:basename.css' do
  file = file_relative "stylesheets/#{params[:basename]}.scss" # Put stylesheets/{anything}.scss into a variable
  last_modified file.mtime # Set last_modified header to file's modified time (for caching)
  scss file.read#, :style => :compressed # Compile scss => css in compressed style
end