class TemplatesController < ApplicationController

  def new
    u = User.find_by(id: session[:user_id])
    p = Person.find_by(id: u.person_id)
    @identifier =  u.person_id
    @person = Person.find_by(id: @identifier)

    #redirect_to '/people'
    @cats=Category.all.order('LOWER(name)').collect {|t| [t.name, t.id, 'isfeedback' => t.is_feedback]}
    @tags=Tag.where(validity: true).order('LOWER(name)')

    if (params[:redirect_url])
      @redirect_url = params[:redirect_url]
    else
      @redirect_url = request.headers["Referer"]
    end
  end

  def create

    @template = Template.create(templates_params)

    @template.tag_ids = params[:tags]
    #CATEGORIES
    category=Category.find(params[:template][:category_id])
    @template.category=category
    
    if params[:template][:doc_url] && (params[:template][:doc_url]!='')
      session = GoogleDrive.login_with_oauth(current_user.oauth_token)
      begin
        f = session.file_by_url(params[:template][:doc_url])
        #se logro encontrar el resorce
        r = Resource.new
        r.doc_id= f.resource_id
        r.title= f.title
        r.url= f.human_url
        r.save!
        @template.resource_id=r.id

      rescue Google::APIClient::ClientError
        #no se logro encontrar el resorce
        if params[:redirect_url]
          redirect_to templates_new_path(:error => true, :redirect_url => params[:redirect_url])
        else
          redirect_to google_adddriveview_path(:error => true)
        end
        return
      rescue GoogleDrive::Error
        #url no es valida
        if params[:redirect_url]
          redirect_to templates_new_path(:error => true, :redirect_url => params[:redirect_url])
        else
          redirect_to google_adddriveview_path(:error => true)
        end
        return
      rescue URI::InvalidURIError
        if params[:redirect_url]
          redirect_to templates_new_path(:error => true, :redirect_url => params[:redirect_url])
        else
          redirect_to google_adddriveview_path(:error => true)
        end
        return
      end
    end

    @template.save!

    if @template.valid?
      flash.notice = "'#{templates_params[:title]}' " + t('messages.create.success')
    else
      flash.alert = "'#{templates_params[:title]}' " + t('messages.create.error')
    end

    if params[:redirect_url]
      redirect_to params[:redirect_url]
    else
      redirect_to root_path
    end
  end

  def index
    @template= Template.all.order('LOWER(title)')
    respond_to do |f|
      f.json { render json: name_and_path(@template)}
      f.html { render }
    end
  end

  def generate
    t = Template.find_by(id: params[:template_id])
    p = Person.find_by(id: params[:person_id])
    if t && p
      m = Milestone.new
      m.title= t.title
      m.description= t.description
      m.category = t.category
      m.icon= t.icon
      m.tags = t.tags
      m.people<<(p)

      #AUTHOR
      m.author_id = current_user.person_id

      #Crear documento adjunto
      if t.resource
        u = current_user
        session = GoogleDrive.login_with_oauth(u.oauth_token)
        begin
          #traigo el archivo
          f = session.file_by_url(t.resource.url)
          #lo copio
          fuploaded = f.copy("#{m.title}")
          #agregar permisos a la gente asociada al hito
          m.people.each do |p|
            fuploaded.acl.push(
                {:type => 'user', :value => p.email, :role => 'writer'})
          end

          #se logro encontrar el resource
          r = Resource.new
          r.doc_id= fuploaded.resource_id
          r.title= fuploaded.title
          r.url= fuploaded.human_url
          m.resources<<(r)

        rescue Google::APIClient::ClientError
          #no se logro encontrar el resorce
          driveerr = t(:driveerrormsj)
        rescue GoogleDrive::Error
          #url no es valida
          driveerr = t(:invalidurl)
        rescue URI::InvalidURIError
          #url no es valida
          driveerr = t(:invalidurl)
        end
      end

      m.save!

      if m.valid?
        if driveerr.nil?
          flash.notice = "'#{t.title}' " + t('messages.create.success')
        else
          flash.notice = "'#{t.title}' " + t('messages.create.success') + " \n(#{t(:driveerrormsj)}: #{driveerr})"
        end
      else
        flash.alert = "'#{t.title}' " + t('messages.create.error')
      end

      redirect_to :back
    else
      redirect_to root_path
    end
  end

  def destroy
    temp = Template.find_by(id: params[:template_id])
    if temp
      temp.destroy
    end
    #redirect_to milestones_path
    redirect_to templates_path
  end

  def templates_params
    params.require(:template).permit(:title, :description, :icon, :category_id, :created_at, :updated_at)
  end
end
