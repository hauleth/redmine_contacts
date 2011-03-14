module ContactsHelper

  def skype_to(skype_name, name = nil)
    return link_to skype_name, 'skype:' + skype_name + '?call' unless skype_name.blank?
  end
  
  def link_to_remote_list_update(text, url_params)
    link_to_remote(text,
      {:url => url_params, :method => :get, :update => 'contact_list', :complete => 'window.scrollTo(0,0)'},
      {:href => url_for(:params => url_params)}
    )
  end
  
  
  def contacts_paginator(paginator, page_options)     
    page_param = page_options.delete(:page_param) || :page
    per_page_links = page_options.delete(:per_page_links)
    url_param = params.dup
    # don't reuse query params if filters are present
    url_param.merge!(:fields => nil, :values => nil, :operators => nil) if url_param.delete(:set_filter)

    html = ''
    if paginator.current.previous
      html << link_to_remote_list_update('&#171; ' + l(:label_previous), url_param.merge(page_param => paginator.current.previous)) + ' '
    end

    html << (pagination_links_each(paginator, page_options) do |n|
      link_to_remote_list_update(n.to_s, url_param.merge(page_param => n))
    end || '')
    
    if paginator.current.next
      html << ' ' + link_to_remote_list_update((l(:label_next) + ' &#187;'), url_param.merge(page_param => paginator.current.next))
    end
    
    html
    
     # pagination_links_each(paginator, page_options) do |link|
    #     options = { :url => {:controller => 'contacts',  :action => 'live_search', :search => '', :project_id => @project, :params => params.merge({:page => link})}, :update => 'contact_list' }
    #     html_options = { :href => url_for(:controller => 'contacts',  :action => 'live_search', :project_id => @project, :params => params.merge({:page => link})) }
    #     # debugger
    #     link_to_remote(link.to_s, options)
    # end         
  end
  
  def contact_url(contact)      
    project_id = @project.blank? ? contact.project : @project  
    return {:controller => 'contacts', :action => 'show', :project_id => project_id, :id => contact.id }
  end

  def note_source_url(note_source) 
    project_id = @project.blank? ? note_source.project : @project       
    return {:controller => note_source.class.name.pluralize.downcase, :action => 'show', :project_id => project_id, :id => note_source.id }
  end
       
  def link_to_source(note_source) 
    return link_to note_source.name, note_source_url(note_source)
  end

  def avatar_to(obj, options = { })  
    options[:size] = "64" unless options[:size]  
    options[:size] = options[:size] + "x" + options[:size] 
    options[:class] = "gravatar"  
    
    avatar = obj.attachments.find_by_description 'avatar' unless Rails::env == "development"
    
    if avatar then  # and obj.visible?
      image_url = url_for :only_path => false, :controller => 'attachments', :action => 'download', :id => avatar, :filename => avatar.filename
      # image_url = url_for :only_path => false, :controller => 'contacts', :action => 'download_avatar', :id => obj, :filename => avatar.filename
      if options[:full_size] then
        return link_to image_tag(image_url, options), image_url
      else 
        return image_tag(image_url, options)
      end  
    elseif obj.email.downcase
      return gravatar(obj.emails.first, options) rescue nil 
    else
      
      plugins_images  =  "/plugin_assets/redmine_contacts/images/"
      if obj.class == Deal   
        image =  image_tag(plugins_images + "deal.png", options)
      end  
      
      if obj.class == Contact
        image =  obj.is_company ? image_tag(plugins_images + "company.png", options) : image_tag(plugins_images + "person.png", options)
      end
      
      return image  
    end
  end
  
  def link_to_add_phone(name)             
    fields = '<p>' + label_tag(l(:field_contact_phone)) + 
      text_field_tag( "contact[phones][]", '', :size => 30 ) + 
      link_to_function(l(:label_remove), "removeField(this)") + '</p>'
    link_to_function(name, h("addField(this, '#{escape_javascript(fields)}' )"))
  end    
  
  def link_to_task_complete(url, bucket)
    onclick = "this.disable();"
    onclick << %Q/$("#{dom_id(pending, :name)}").style.textDecoration="line-through";/
    onclick << remote_function(:url => url, :method => :put, :with => "{ bucket: '#{bucket}' }")
  end   
  
  def render_contact_projects_hierarchy(projects)  
    s = ''
    project_tree(projects) do |project, level| 
      s << "<ul>"
      name_prefix = (level > 0 ? ('&nbsp;' * 2 * level + '&#187; ') : '')
        url = {:controller => 'contacts',
               :action => 'disconnect_project',
               :project_id => project.id}
      
      s << "<li>" + name_prefix + link_to_project(project)
      s += ' ' + link_to_remote(image_tag('delete.png'),
                                {:url => url},
                                :href => url_for(url),
                                :style => "vertical-align: middle",
                                :class => "delete") unless project == @project         
      s << "</li>"                          

      s << "</ul>"
    end
    s
  end  
    
  #   s = ''
  #   if projects.any?
  #     ancestors = []
  #     original_project = @project
  #     projects.each do |project|
  #       # set the project environment to please macros.
  #       @project = project
  #       if (ancestors.empty? || project.is_descendant_of?(ancestors.last))
  #         s << "<ul class='projects #{ ancestors.empty? ? 'root' : nil}'>\n"
  #       else
  #         ancestors.pop
  #         s << "</li>"
  #         while (ancestors.any? && !project.is_descendant_of?(ancestors.last)) 
  #           ancestors.pop
  #           s << "</ul></li>\n"
  #         end
  #       end
  #       classes = (ancestors.empty? ? 'root' : 'child')
  #       s << "<li class='#{classes}'><div class='#{classes}'>" +
  #              link_to_project(project)
  #       ancestors << project
  #     end
  #     s << ("</li></ul>\n" * ancestors.size)
  #     @project = original_project
  #   end
  #   s
  # end 
  
end
