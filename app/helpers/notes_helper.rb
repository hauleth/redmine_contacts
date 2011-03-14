module NotesHelper   
  
  def add_note_ajax(note, note_source, show_info = false)
    render :update do |page|   
      page[:add_note_form].reset
      page.insert_html :top, "notes", :partial => 'notes/note_item', :object => note, :locals => {:show_info => show_info, :note_source => note_source}
      page["note_#{@note.id}"].visual_effect :highlight 
    end
  end
end
