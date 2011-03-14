class ContactsController < ApplicationController
  unloadable    
  
  Mime::Type.register "text/x-vcard", :vcf     
  
  default_search_scope :contacts    
  
  before_filter :find_optional_project
  before_filter :find_contact, :except => [:index, :new, :create, :live_search, :contacts_notes, :close_issue, :contacts_issues, :destroy_note, :add_contact_to_issue, :add_contact_to_project]
  before_filter :build_new_contact_from_params, :only => [:new, :create] 
 
  helper :attachments
  helper :contacts  
  helper :watchers  
  include WatchersHelper
  
  
  def show
    find_contact_attachments
    
    if @contact.is_company 
      find_employees
                            
     
      @notes_pages, @notes = paginate :notes,
                                      :per_page => 30,
                                      :conditions => {:source_id  => Contact.order_by_name.find_all_by_company(@contact.first_name).map(&:id) << @contact.id,  
                                                     :source_type => 'Contact'},
                                      :order => "created_on DESC" 
    else
      find_company
      @notes_pages, @notes = paginate :notes, 
                                      :per_page => 30,
                                      :conditions => {:source_id => @contact.id, :source_type => 'Contact'},
                                      :order => "created_on DESC"
      
    end  
    respond_to do |format|
      format.js if request.xhr?
      format.html {}
      format.xml { render :xml => @contact }   
      format.json { render :text => @contact.to_json, :layout => false } 
      format.vcf do              
        if Gem.available?('vpim') 
          require 'vpim/vcard'   
          export_to_vcard(@contact) 
        end  
      end
    end
  end
  
  def index    
    if !request.xhr?
      last_notes
      find_tags       
    end
    find_contacts
    @contacts.sort! {|x, y| x.name <=> y.name }     
    # debugger       
    respond_to do |format|   
      format.html { render :partial => "list", :layout => false, :locals => {:contacts => @contacts} if request.xhr?} 
      format.xml { render :xml => @contacts }  
      format.json { render :text => @contacts.to_json, :layout => false } 
    end
    
    #@contacts = Contact.find(:all)
  end
  
  def edit    
    #@contact = Contact.find_by_id(params[:id])
  end

  def update
    #@contact = Contact.find_by_id(params[:id])   
    # debugger
    if @contact.update_attributes(params[:contact])
      flash[:notice] = l(:notice_successful_update)     
      # debugger
      avatar = @contact.attachments.find_by_description 'avatar' 
      if params[:contact_avatar]    
        avatar.destroy if avatar  
        params[:contact_avatar][:description] = 'avatar'      
        
        if Redmine::VERSION.to_s >= "1.0.0"
           Attachment.attach_files(@contact, {"1" => params[:contact_avatar]})     
         else                                                                 
           attach_files(@contact, {"1" => params[:contact_avatar]}) 
         end
        
        
      end
      redirect_to :action => "show", :project_id => params[:project_id], :id => @contact
    else
      render "edit", :project_id => params[:project_id], :id => @contact  
    end
  end

  def destroy
    #@contact = Contact.find_by_id(params[:id])
    if @contact.destroy
      flash[:notice] = l(:notice_successful_delete)
    else
      flash[:error] = l(:notice_unsuccessful_save)
    end
    redirect_to :action => "index", :project_id => params[:project_id]
  end
  
  def new
    @contact = Contact.new   
    @contact.company = params[:company_name] if params[:company_name] 
  end

  def create
    @contact = Contact.new(params[:contact])
    @contact.projects << @project 
    @contact.author = User.current
    if @contact.save
      flash[:notice] = l(:notice_successful_create)
      if params[:contact_avatar]    
        params[:contact_avatar][:description] = 'avatar'     
        if Redmine::VERSION.to_s >= "1.0.0"
          Attachment.attach_files(@contact, {"1" => params[:contact_avatar]})     
        else                                                                 
          attach_files(@contact, {"1" => params[:contact_avatar]}) 
        end
      end
      
      redirect_to :action => "show", :project_id => params[:project_id], :id => @contact
    else  
      render :action => "new"
    end
  end

 
  def edit_tags   
    @contact.tags.clear
    @contact.update_attributes(params[:contact])
    respond_to do |format|
      format.js if request.xhr?
      format.html {redirect_to :action => 'show', :id => @contact, :project_id => @project}
    end
  end
  
  def add_task
    issue = Issue.new
    issue.subject = params[:task_subject]
    issue.project = @project
    issue.tracker_id = params[:task_tracker]
    issue.author = User.current
    issue.due_date = params[:due_date]
    issue.assigned_to_id = params[:assigned_to]
    issue.description = params[:task_description]
    issue.status = IssueStatus.default
    if issue.save
      flash[:notice] = l(:notice_successful_add)
      @contact.issues << issue
      @contact.save
      redirect_to :action => 'show', :id =>  params[:id], :project_id => params[:project_id]
      return
    else
      redirect_to :action => 'show', :id =>  params[:id], :project_id => params[:project_id] 
    end           
  end   
 
  def add_contact_to_project
    project = Project.find(params[:project_id])     
    @show_form = "true"          
    find_contact
    if params[:new_project_id] then    
      project = Project.find(params[:new_project_id])
      @contact.projects << project
      @contact.save if request.post?   
    end
    respond_to do |format|
      format.html { redirect_to :back }  
      # format.html { redirect_to :controller => 'issues', :action => 'show', :id => params[:issue_id] }     
      format.js do
        render :update do |page|   
          page.replace_html 'contact_projects', :partial => 'related_projects'
        end
      end
    end
    
  end
  
  def add_contact_to_issue 
    @issue = Issue.find(params[:issue_id])     
    @show_form = "true"
    if params[:id] then    
      find_contact
      @contact.issues << @issue
      @contact.save if request.post?   
    end
    respond_to do |format|
      format.html { redirect_to :back }  
      # format.html { redirect_to :controller => 'issues', :action => 'show', :id => params[:issue_id] }     
      format.js do
        render :update do |page|   
          page.replace_html 'issue_contacts', :partial => 'issues/contacts'
        end
      end
    end

  end
  
  def destroy_contact_from_issue    
    @issue = Issue.find(params[:issue_id])   
    @issue.contacts.delete(@contact)
    respond_to do |format|
      format.html { redirect_to :back }
      format.js do
        render :update do |page|
          page.replace_html 'issue_contacts', :partial => 'issues/contacts'
        end
      end
    end    
  end
  
    
  def add_note
    @note = Note.new(params[:note])
    @note.author = User.current   
    @note.created_on = @note.created_on + Time.now.hour.hours + Time.now.min.minutes + Time.now.sec.seconds if @note.created_on
    if @contact.notes << @note    
      
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
        format.html {redirect_to :action => 'show', :id => @contact, :project_id => @project}
      end
    else
        # TODO При render если коммент не добавился то тут появялется ошибка из-за того что не передаются данные для paginate
      redirect_to :action => 'show', :id => @contact, :project_id => @project   
    end                   
  end

  def destroy_note   
    @note = Note.find(params[:note_id])
    @contact = @note.source
    @note.destroy
    respond_to do |format|
      format.js do 
        render :update do |page|  
            page["note_#{params[:note_id]}"].visual_effect :fade 
        end
      end if request.xhr?       
      format.html {redirect_to :action => 'show', :project_id => @contact.projects.first, :id => @contact }
    end
    
    # redirect_to :action => 'show', :project_id => @project, :id => @contact
  end
      
  def close_issue
    issue = Issue.find(params[:issue_id])
    issue.status = IssueStatus.find(:first, :conditions =>  { :is_closed => true })    
    issue.save
    respond_to do |format|
      format.js do 
        render :update do |page|  
            page["issue_#{params[:issue_id]}"].visual_effect :fade 
        end
      end     
      format.html {redirect_to :back }
    end
    
  end     
  
  def contacts_notes  
    unless request.xhr?  
      find_tags
    end  
    # @notes = Comment.find(:all, 
    #                            :conditions => { :commented_type => "Contact", :commented_id => find_contacts.map(&:id)}, 
    #                            :order => "updated_on DESC")  
   
    joins = " "
    joins << " LEFT OUTER JOIN #{Contact.table_name} ON #{Note.table_name}.source_id = #{Contact.table_name}.id AND #{Note.table_name}.source_type = 'Contact' "
    joins << " LEFT OUTER JOIN #{Deal.table_name} ON #{Note.table_name}.source_id = #{Deal.table_name}.id AND #{Note.table_name}.source_type = 'Deal' "

    cond = "(1 = 1) " 
    cond << "and (#{Contact.table_name}.id in (#{find_contacts(false).any? ? @contacts.map(&:id).join(', ') : 'NULL'})"
    cond << " or #{Deal.table_name}.id in (#{find_deals.any? ? @deals.map(&:id).join(', ') : 'NULL'}))"    
    cond << " and (#{Note.table_name}.content LIKE '%#{params[:search_note]}%')" if params[:search_note] and request.xhr?
   
    @notes_pages, @notes = paginate :notes,
                                    :per_page => 20, 
                                    :joins => joins,      
                                    :conditions => cond, 
                                    :order => "created_on DESC"   
    @notes.compact!   
    
    
    respond_to do |format|   
      format.html { render :partial => "notes/notes_list", :layout => false, :locals => {:notes => @notes, :notes_pages => @notes_pages} if request.xhr?} 
      format.xml { render :xml => @notes }  
    end
  end
             
  def contacts_issues   
    cond = "(1=1)"
    # cond = "issues.assigned_to_id = #{User.current.id}"
    cond << " and issues.project_id = #{@project.id}" if @project      
    cond << " and (issues.assigned_to_id = #{params[:assigned_to]})" unless params[:assigned_to].blank?
    
    @contacts_issues = Issue.visible.find(:all, 
                                          :joins => "INNER JOIN contacts_issues ON issues.id = contacts_issues.issue_id", 
                                          :group => :issue_id,
                                          :conditions => cond,
                                          :order => "issues.due_date")    
    @users = assigned_to_users                                      
  end   
            
  # Authorize the user for the requested action
  def authorize_for_contact(contact, ctrl = params[:controller], action = params[:action])    

    return true if contact.public?
    
    return false if contact.private? and User.current != contact.author

    allowed = User.current.allowed_to?({:controller => ctrl, :action => action}, contact.projects, :global => true)  
    if allowed
      true
    else
      deny_access
    end
  end
  
  
private
  def build_new_contact_from_params
    
  end           
  
  def export_to_vcard(contact)
    card = Vpim::Vcard::Maker.make2 do |maker|

      maker.add_name do |name|
        name.prefix = ''
        name.given = contact.first_name
        name.family = contact.last_name
        name.additional = contact.middle_name
      end

      maker.add_addr do |addr|
        addr.preferred = true
        addr.street = contact.address
      end
      
      maker.title = contact.job_title
      maker.org = contact.company   
      maker.birthday = contact.birthday.to_date unless contact.birthday.blank?
      
      maker.add_note(contact.background.gsub("\r", '').gsub("\n", ''))
       
      maker.add_url(contact.website)

      contact.phones.each { |phone| maker.add_tel(phone) }
      contact.emails.each { |email| maker.add_email(email) }
    end   
    avatar = contact.attachments.find_by_description('avatar')  
    card = card.encode.sub("END:VCARD", "PHOTO;BASE64:" + "\n " + [File.open(avatar.diskfile).read].pack('m').to_s.gsub(/[ \n]/, '').scan(/.{1,76}/).join("\n ") + "\nEND:VCARD") if avatar && avatar.readable?
    
    send_data card.to_s, :filename => "contact.vcf", :type => 'text/x-vcard;', :disposition => 'attachment'	
    
  end

  def last_notes(count=5)      
    cond = "(1 = 1)"
    cond << " and project_id = #{@project.id}" if @project
    
      @last_notes = Note.find(:all, 
                                 :conditions => { :source_type => "Contact", :source_id => find_contacts(false).map(&:id)}, 
                                 :limit => count,
                                 :order => "created_on DESC").collect{|obj| obj if obj.source.visible?}.compact                    
  end
  
  def find_project      
    
    @project = Project.find(params[:project_id]) if params[:project_id]
    
    rescue ActiveRecord::RecordNotFound
      render_404
  end

  def find_contact
    @contact = Contact.find(params[:id])   
    authorize_for_contact(@contact) 
    # @project = @contact.project if @project.blank?
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  def find_tags     
    cond  = ARCondition.new  
    cond << ["#{Contact.table_name}.id IN (SELECT contact_id from contacts_projects where project_id = ?)", @project.id] if @project
    cond << ["#{Contact.table_name}.id IN (SELECT contact_id from contacts_projects where project_id in (SELECT projects.id FROM projects WHERE #{Project.allowed_to_condition(User.current, :view_contacts)}))"]   
    options = {}
    options[:conditions] = cond.conditions  
     
    @tags = Contact.all_tag_counts(options)
  end
  
  def find_employees
    @employees = Contact.order_by_name.find_all_by_company(@contact.first_name)
  end
 
  def find_contact_attachments 
    @contact_attachments = Attachment.find(:all, 
                                    :conditions => { :container_type => "Note", :container_id => @contact.notes.map(&:id)},   
                                    :order => "created_on DESC")
  end

  def find_company
    @company = Contact.find_by_first_name(@contact.company)
  end
  
  def find_deals   
    cond  = ARCondition.new         
    cond << ["#{Deal.table_name}.project_id = ?", @project.id] if @project  
    cond << ["#{Deal.table_name}.name LIKE ? ", "%" + params[:search] + "%"] if params[:search] and request.xhr?  

    cond << ["1=0"] if params[:tag]
      
    @deals = Deal.visible.find(:all, :conditions => cond.conditions) || []
  end
  
  def find_contacts(pages=true)   
    @tag = ActsAsTaggableOn::TagList.from(params[:tag]).map{|tag| ActsAsTaggableOn::Tag.find_by_name(tag) } unless params[:tag].blank? 

    cond  = ARCondition.new      
    cond << ["#{Contact.table_name}.job_title = ?", params[:job_title]] unless params[:job_title].blank? 
    cond << ["#{Contact.table_name}.assigned_to_id = ?", params[:user]] unless params[:user].blank? 
    cond << ["(#{Contact.table_name}.first_name LIKE ? or 
              #{Contact.table_name}.last_name LIKE ? or 
              #{Contact.table_name}.middle_name LIKE ? or 
              #{Contact.table_name}.company LIKE ? or 
              #{Contact.table_name}.job_title LIKE ?)", 
                       "%" + params[:search] + "%",
                       "%" + params[:search] + "%",
                       "%" + params[:search] + "%",
                       "%" + params[:search] + "%",
                       "%" + params[:search] + "%"

                       ] if params[:search] and request.xhr? 
                                                             
    flash[:warning] = "ver 1.2.0 beta - Error in ACL if you add project to contact, you can't view or edit contact and his avatar"
    scope = Contact.scoped({}) 
    scope = scope.in_project(@project.id) if @project
    scope = scope.visible unless @project 
    
    scope = scope.tagged_with(params[:tag]) unless params[:tag].blank?  
    scope = scope.scoped :conditions => cond.conditions
      
    if pages  
      @contacts_pages = Paginator.new(self, scope.count, 20, params[:page])     
      offset = @contacts_pages.current.offset  
      limit =  @contacts_pages.items_per_page
      scope = scope.scoped :limit  => limit, :offset => offset if @contacts_pages.count > 1
    end
    
    @contacts = scope.order_by_name
  end     
  
  def assigned_to_users
    user_values = []  
    project = @project
    user_values << ["<< #{l(:label_all)} >>", ""]
    user_values << ["<< #{l(:label_me)} >>", User.current.id] if User.current.logged?
    if project
      user_values += project.users.sort.collect{|s| [s.name, s.id.to_s] }
    else
      project_ids = Project.all(:conditions => Project.visible_by(User.current)).collect(&:id)
      if project_ids.any?
        # members of the user's projects
        user_values += User.active.find(:all, :conditions => ["#{User.table_name}.id IN (SELECT DISTINCT user_id FROM members WHERE project_id IN (?))", project_ids]).sort.collect{|s| [s.name, s.id.to_s] }
      end
    end    
  end
  
  def find_optional_project
    return true unless params[:project_id]
    @project = Project.find(params[:project_id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  

end
