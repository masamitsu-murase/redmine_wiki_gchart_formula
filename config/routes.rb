
ActionController::Routing::Routes.draw do |map|
  map.connect 'wiki_gchart_formula/issues/:id.pdf', :controller => 'wiki_gchart_formula', :action => "show", :format => "pdf"
end
