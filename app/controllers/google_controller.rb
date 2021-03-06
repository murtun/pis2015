  require 'pp'
  require 'rubygems'
  require 'google/api_client'
  require 'google_drive'

class GoogleController < ApplicationController

  skip_before_action :loged?, only:[:callback,:unregistered]
  skip_before_action :admin?

  #
  # Login con Google y OAuth2
  #
  def callback
    auth = env['omniauth.auth']

    person = Person.find_by(email: auth.info.email)
    if person
      user =  User.find_by(person: person)
      if not user
        user = User.new
        user.person = person
      end
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!

      session[:user_id] = user.id
      if person.mentees.empty? && !person.admin?
        redirect_to root_path
      else
        redirect_to '/dashboard/'
      end

    else
      redirect_to google_unregistered_path
    end
  end

  def signout
    session[:user_id] = nil
    redirect_to root_path
  end

  def unregistered
    if  current_user
      redirect_to root_path
    end
  end

  #
  # Google Drive
  #
  def adddriveview
    if params[:milestone_id] && can_modify_milestone?(params[:milestone_id])
      @milestone_id = params[:milestone_id]
      #@redirect_url = request.env['HTTP_REFERER']
      if (params[:redirect_url])
        @redirect_url = params[:redirect_url]
      else
        @redirect_url = request.headers["Referer"]
      end
    else
      redirect_to root_path
    end
  end

  def adddrive
    url = params[:URL]
    @milestone_id = params[:milestone_id]
    m = Milestone.find_by(id: @milestone_id)
    u = current_user

    if m and u and url
      session = GoogleDrive.login_with_oauth(u.oauth_token)

      begin
        f = session.file_by_url(url)
        #se logro encontrar el resorce
        r = Resource.new
        r.doc_id= f.resource_id
        r.title= f.title
        r.url= f.human_url
        m.resources<<(r)
        m.updated_at= Time.now
        m.save!
      rescue Google::APIClient::ClientError
        #no se logro encontrar el resorce
        r = Resource.new
        r.title= url
        r.url= url
        m.resources<<(r)
        m.updated_at= Time.now
        m.save!
      rescue GoogleDrive::Error
        #url no es valida
        if params[:redirect_url]
          redirect_to google_adddriveview_path(:milestone_id => @milestone_id, :error => true, :redirect_url => params[:redirect_url])
        else
          redirect_to google_adddriveview_path(:milestone_id => @milestone_id, :error => true)
        end
        return
      rescue URI::InvalidURIError
        if params[:redirect_url]
          redirect_to google_adddriveview_path(:milestone_id => @milestone_id, :error => true, :redirect_url => params[:redirect_url])
        else
          redirect_to google_adddriveview_path(:milestone_id => @milestone_id, :error => true)
        end
        return
      end
    end
      if params[:redirect_url]
        redirect_to params[:redirect_url]
      else
        redirect_to root_path
      end
  end

  def checkurl
    url = params[:URL]
    u = current_user
    result = :error

    if u and url
      session = GoogleDrive.login_with_oauth(u.oauth_token)

      begin
        f = session.file_by_url(url)
        #se logro encontrar el resorce
        result = :ok

      rescue Google::APIClient::ClientError
        #no se logro encontrar el resorce
        result = :notfound

      rescue GoogleDrive::Error
        #url no es valida
        result = :invalid

      rescue URI::InvalidURIError
        #url no es valida
        result = :invalid

      end
    end

    respond_to do |format|
      format.json  { render :json => result }
    end
  end
end