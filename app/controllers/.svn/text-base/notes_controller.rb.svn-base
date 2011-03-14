class NotesController < ApplicationController
  unloadable
  
  before_filter :find_project, :authorize, :except => []

  def new
  end

  def edit
  end

  def add_note
    @note = Note.new(params[:note])
    @note.author = User.current   
    @note.created_on = @note.created_on + Time.now.hour.hours + Time.now.min.minutes + Time.now.sec.seconds if @note.created_on
    if @note_source.notes << @note    
      
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
            page.insert_html :top, "notes", :partial => 'notes/note_item', :object => @note, :locals => {:show_info => @contact.is_company, :note_source => @contact}
            page["note_#{@note.id}"].visual_effect :highlight    
            flash.discard   
          end
        end if request.xhr?       
        format.html {redirect_to :back}
      end
    else
        # TODO При render если коммент не добавился то тут появялется ошибка из-за того что не передаются данные для paginate
      redirect_to :action => 'show', :id => @contact, :project_id => @project   
    end                   
  end    
  
  private
  
  def find_project
    @project = Project.find(params[:project_id])
    
  # rescue ActiveRecord::RecordNotFound
  #   render_404
  end
  
  def find_note_source
    klass = Object.const_get(params[:object_type].camelcase)
    # return false unless klass.respond_to?('watched_by')
    @note_source = klass.find(params[:object_id])
  end

end
