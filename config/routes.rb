# == Route Map
#
#                      Prefix Verb   URI Pattern                                            Controller#Action
#                        root GET    /                                                      people#me
#               welcome_index GET    /welcome/index(.:format)                               welcome#index
#     person_assign_milestone POST   /people/:person_id/assign_milestone(.:format)          people#assign_milestone
#                   me_people GET    /people/me(.:format)                                   people#me
#           add_mentor_people POST   /people/add_mentor(.:format)                           people#add_mentor
#      add_mentor_form_people GET    /people/add_mentor_form(.:format)                      people#add_mentor_form
#                      people GET    /people(.:format)                                      people#index
#                             POST   /people(.:format)                                      people#create
#                  new_person GET    /people/new(.:format)                                  people#new
#                 edit_person GET    /people/:id/edit(.:format)                             people#edit
#                      person GET    /people/:id(.:format)                                  people#show
#                             PATCH  /people/:id(.:format)                                  people#update
#                             PUT    /people/:id(.:format)                                  people#update
#                             DELETE /people/:id(.:format)                                  people#destroy
#                    projects GET    /projects(.:format)                                    projects#index
#                             POST   /projects(.:format)                                    projects#create
#                 new_project GET    /projects/new(.:format)                                projects#new
#                edit_project GET    /projects/:id/edit(.:format)                           projects#edit
#                     project GET    /projects/:id(.:format)                                projects#show
#                             PATCH  /projects/:id(.:format)                                projects#update
#                             PUT    /projects/:id(.:format)                                projects#update
#                             DELETE /projects/:id(.:format)                                projects#destroy
#                        tags GET    /tags(.:format)                                        tags#index
#                             POST   /tags(.:format)                                        tags#create
#                     new_tag GET    /tags/new(.:format)                                    tags#new
#                    edit_tag GET    /tags/:id/edit(.:format)                               tags#edit
#                         tag GET    /tags/:id(.:format)                                    tags#show
#                             PATCH  /tags/:id(.:format)                                    tags#update
#                             PUT    /tags/:id(.:format)                                    tags#update
#                             DELETE /tags/:id(.:format)                                    tags#destroy
#             milestone_notes GET    /milestones/:milestone_id/notes(.:format)              notes#index
#                             POST   /milestones/:milestone_id/notes(.:format)              notes#create
#          new_milestone_note GET    /milestones/:milestone_id/notes/new(.:format)          notes#new
#         edit_milestone_note GET    /milestones/:milestone_id/notes/:id/edit(.:format)     notes#edit
#              milestone_note GET    /milestones/:milestone_id/notes/:id(.:format)          notes#show
#                             PATCH  /milestones/:milestone_id/notes/:id(.:format)          notes#update
#                             PUT    /milestones/:milestone_id/notes/:id(.:format)          notes#update
#                             DELETE /milestones/:milestone_id/notes/:id(.:format)          notes#destroy
#      milestone_add_category POST   /milestones/:milestone_id/add_category(.:format)       milestones#add_category
#       milestone_next_status POST   /milestones/:milestone_id/next_status(.:format)        milestones#next_status
#       milestone_set_as_done GET    /milestones/:milestone_id/set_as_done(.:format)        milestones#set_as_done
#                  milestones GET    /milestones(.:format)                                  milestones#index
#                             POST   /milestones(.:format)                                  milestones#create
#               new_milestone GET    /milestones/new(.:format)                              milestones#new
#              edit_milestone GET    /milestones/:id/edit(.:format)                         milestones#edit
#                   milestone GET    /milestones/:id(.:format)                              milestones#show
#                             PATCH  /milestones/:id(.:format)                              milestones#update
#                             PUT    /milestones/:id(.:format)                              milestones#update
#                             DELETE /milestones/:id(.:format)                              milestones#destroy
#         category_milestones GET    /categories/:category_id/milestones(.:format)          milestones#index
#                             POST   /categories/:category_id/milestones(.:format)          milestones#create
#      new_category_milestone GET    /categories/:category_id/milestones/new(.:format)      milestones#new
#     edit_category_milestone GET    /categories/:category_id/milestones/:id/edit(.:format) milestones#edit
#          category_milestone GET    /categories/:category_id/milestones/:id(.:format)      milestones#show
#                             PATCH  /categories/:category_id/milestones/:id(.:format)      milestones#update
#                             PUT    /categories/:category_id/milestones/:id(.:format)      milestones#update
#                             DELETE /categories/:category_id/milestones/:id(.:format)      milestones#destroy
#                  categories GET    /categories(.:format)                                  categories#index
#                             POST   /categories(.:format)                                  categories#create
#                new_category GET    /categories/new(.:format)                              categories#new
#               edit_category GET    /categories/:id/edit(.:format)                         categories#edit
#                    category GET    /categories/:id(.:format)                              categories#show
#                             PATCH  /categories/:id(.:format)                              categories#update
#                             PUT    /categories/:id(.:format)                              categories#update
#                             DELETE /categories/:id(.:format)                              categories#destroy
# auth_google_oauth2_callback GET    /auth/google_oauth2/callback(.:format)                 google#callback
#                auth_failure GET    /auth/failure(.:format)                                redirect(301, /)
#              google_signout GET    /google/signout(.:format)                              google#signout
#         google_unregistered GET    /google/unregistered(.:format)                         google#unregistered
#         google_adddriveview GET    /google/adddriveview(.:format)                         google#adddriveview
#             google_adddrive GET    /google/adddrive(.:format)                             google#adddrive
#           google_driveerror GET    /google/driveerror(.:format)                           google#driveerror
#

Rails.application.routes.draw do

  root to: 'people#me'

  get 'welcome/index'

  resources :people do
    resources :milestones
    post :assign_milestone
    post :assign_project
    post :switch_admin
    get :show_pending_timeline
    get :show_not_pending_timeline
    get :show_timeline_cat_fil
    collection do
      get 'me'
      post 'switch_admin'
      post 'add_mentor'
      get 'add_mentor_form'
      post 'remove_mentor'
      get 'remove_mentor_form'
      post 'add_skill'
      get 'add_skill_form'
      post 'remove_skill'
      get 'remove_skill_form'
      post 'edit_profile_pic'
      get 'edit_profile_pic_form'
      get 'new' => 'people#new'
      post 'new' => 'people#create'
      get ':id' => 'people#show', :constraints  => { :id => /[-\w\.]+/ }
    end
  end

  resources :projects do
    post :assign_person

    collection do
      get 'new' => 'projects#new'
      post 'new' => 'projects#create'
      get 'unassign_person' =>  'projects#unassign_person'
      get ':id' => 'projects#show', :constraints  => { :id => /[-\w\.]+/ }
      #get 'index' => 'projects#index', as: 'index'

    end
  end

  resources :tags

  resources :tech_roles

  resources :skills do
    post :activate
  end

  #hitos
  get 'milestones/report' => 'milestones#report'
  post 'milestones/report' => 'milestones#report'
  resources :milestones do
    resources :notes
    resources :objectives do
      post :check
    end
    post :add_category
    post :next_status
    post :next_status_rej
    post :highlight
    get :set_as_done
  end
  post 'milestones/new' => 'milestones#create'

  #templates
  get 'templates/new'
  post 'templates/new' => 'templates#create'
  get 'templates' => 'templates#index'
  get '/templates/destroy'
  get '/templates/generate'

  #collections
  get '/collections/destroy'
  get '/collections/generate'
  resources :collections do
    collection do
      get '' => 'collections#index'
      get 'new' => 'collections#new'
      post 'new' => 'collections#create'
    end
  end



  get '/categories/destroy'

  resources :categories do
    post :activate
    resources :milestones

    collection do
      post 'activate'
    end
  end


  # Technologies
  resources :technologies

  # Google auth
  get '/auth/google_oauth2/callback', to: 'google#callback'
  get 'auth/failure', to: redirect('/')
  get 'google/signout'
  get 'google/unregistered'
  #google drive
  get 'google/adddriveview'
  get 'google/adddrive'
  get 'google/driveerror'
  get 'google/checkurl', :defaults => { :format => 'json' }

  #dashboard
  get  '/dashboard' => 'dashboard#index'
  post '/dashboard' => 'dashboard#index'


  get "/commands" => "commands#index", defaults: {format: :json}

end
