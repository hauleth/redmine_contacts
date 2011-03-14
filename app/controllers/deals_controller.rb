class DealsController < ApplicationController
  unloadable     
  
  PRICE_TYPE_PULLDOWN = [l(:label_price_fixed_bid), l(:label_price_per_hour)]
  
  before_filter :find_project, :authorize, :except => [:index, :destroy_note]
  before_filter :find_optional_project, :only => [:index]   
  before_filter :find_deals, :only => :index
  before_filter :find_deal, :only => [:show, :edit, :update, :add_note, :destroy]     
  before_filter :update_deal_from_params, :only => [:edit, :update]
  before_filter :build_new_deal_from_params, :only => [:new, :create]  
  before_filter :find_deal_attachments, :only => :show
 
  helper :attachments
  helper :contacts
  helper :watchers
  include WatchersHelper
  
  def new
    @deal = Deal.new  
    @deal.contacts = [Contact.find(params[:contact_id])] if params[:contact_id] 
    if @contacts.empty?
      redirect_to :action => "index", :project_id  =>  @project     
    end  
  end

  def create   
    @deal = Deal.new(params[:deal])  
    @deal.contacts = [Contact.find(params[:contacts])]
    @deal.project = @project 
    @deal.author = User.current      
    if @deal.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => "show", :project_id => params[:project_id], :id => @deal
    else
      render :action => "new"   
    end
  end
  
  def update  
    if @deal.update_attributes(params[:deal]) 
      @deal.contacts = [Contact.find(params[:contacts])] if params[:contacts]
      flash[:notice] = l(:notice_successful_update)  
      respond_to do |format| 
        format.html { redirect_to :action => "show", :id => @deal, :project_id => params[:project_id]} 
        format.xml  { } 
      end  
    else           
      respond_to do |format|
        format.html { render :action => "edit"}
      end
    end
    
  end
  
  def edit   
    respond_to do |format|
      format.html { }
      format.xml  { }
    end
  end

  def index
  end

  def show
    respond_to do |format|
      format.html { }
      format.xml  { }
    end
  end

  def destroy  
    if @deal.destroy
      flash[:notice] = l(:notice_successful_delete)
    else
      flash[:error] = l(:notice_unsuccessful_save)
    end
    redirect_to :action => "index", :project_id => params[:project_id]
    
  end
  
  def add_note
    @note = Note.new(params[:note])
    @note.author = User.current   
    @note.created_on = @note.created_on + Time.now.hour.hours + Time.now.min.minutes + Time.now.sec.seconds if @note.created_on                                                                                            
    if @deal.notes << @note  
       
      if Redmine::VERSION.to_s >= "1.0.0"
        Attachment.attach_files(@note, params[:note_attachments])    
      else                                                                 
        attach_files(@note, params[:note_attachments])
      end
      
      flash[:notice] = l(:label_note_added)
      respond_to do |format|
        format.js do 
          render :update do |page|   
            page[:add_note_form].reset
            page.insert_html :top, "notes", :partial => 'notes/note_item', :object => @note, :locals => {:show_info => true, :note_source => @deal}
            page["note_#{@note.id}"].visual_effect :highlight    
            flash.discard   
          end
        end if request.xhr?       
        format.html {redirect_to :action => 'show', :id => @deal, :project_id => @project}
      end
    else
      redirect_to :action => 'show', :id => @deal, :project_id => @project
    end                   
  end  
  
  def destroy_note
    @note = Note.find(params[:note_id])
    @deal = @note.source
    @note.destroy
    respond_to do |format|
      format.js do 
        render :update do |page|  
            page["note_#{params[:note_id]}"].visual_effect :fade 
        end
      end if request.xhr?       
      format.html {redirect_to :action => 'show', :project_id => @project, :id => @deal }
    end
  end
  
  
  private
  
  def build_new_deal_from_params
    find_contacts
  end
  
  def update_deal_from_params
    find_contacts  
  end
 
  def find_contacts    
    @contacts = Contact.find(:all, :conditions => {:project_id => @project}, :order => "last_name, first_name")
  end
  
  def find_project
    @project = Project.find(params[:project_id]) unless params[:project_id].blank?
  end
  
  def find_deal_attachments 
    @deal_attachments = Attachment.find(:all, 
                                    :conditions => { :container_type => "Note", :container_id => @deal.notes.map(&:id)},   
                                    :order => "created_on DESC")
  end
  
  
  def find_deals     
    cond = "1 = 1"
    cond << " and project_id = #{@project.id}" if @project
    # debugger
    @deals = Deal.find(:all, :conditions => cond, :order => :status_id).collect{|deal| deal if  deal.visible?}.compact 
  end
  
  def find_deal
    @deal = Deal.find(params[:id]) unless params[:project_id].blank?
  end
 
  def find_optional_project
    return true unless params[:project_id]
    @project = Project.find(params[:project_id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
end
