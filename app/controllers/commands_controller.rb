class CommandsController < ApplicationController

  skip_before_action :index

  respond_to :json

  def index

    commands = [
      { "name" => "Ver mi perfil"   , "url" => "/people/me"         },
      { "name" => "Crear usuario"   , "url" => "/people/new"        },
      { "name" => "Cerrar sesion"   , "url" => "/google/signout"    },
      { "name" => "Ver personas"    , "url" => "/people/"           },
      { "name" => "Ver hitos"       , "url" => "/milestones/"       },
      { "name" => "Ver categorias"  , "url" => "/categories/"       },
      { "name" => "Ver proyectos"   , "url" => "/projects/"         },
      { "name" => "Ver tags"        , "url" => "/tags/"             },
      { "name" => "Ver roles técnicos", "url" => "/tech_roles/"     },
      { "name" => "Crear categoria" , "url" => "/categories/new"    },
      { "name" => "Crear proyecto"  , "url" => "/projects/new"      },
      { "name" => "Crear hito"      , "url" => "/milestones/new"    },
      { "name" => "Ver dashboard"      , "url" => "/dashboard/"     },
      { "name" => "Ver plantillas"      , "url" => "/templates/"    },
      { "name" => "Ver tecnologias"      , "url" => "/technologies/"    },
      { "name" => "Ver colecciónes"      , "url" => "/collections/"  },
      { "name" => "Ver habilidades"      , "url" => "/skills/"  },
    ]

    respond_with commands
  end

end
