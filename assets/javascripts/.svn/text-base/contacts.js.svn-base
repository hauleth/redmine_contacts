var phoneFieldCount = 1;
function addPhoneField() {
    if (phoneFieldCount >= 5) return false
    phoneFieldCount++;

 	var l = document.createElement("label");
	l.appendChild(document.createTextNode(""));

    var d = document.createElement("input");
    d.name = "contact[phones][]";
    d.type = "text";
	d.size = "30";

    p = document.getElementById("phones_fields");

 	k = p.insertBefore(document.createElement("p"));  
    k.appendChild(l);
    k.appendChild(d);

}         
       

var noteFileFieldCount = 1;

function addNoteFileField() {
    if (noteFileFieldCount >= 10) return false
    noteFileFieldCount++;
    var f = document.createElement("input");
    f.type = "file";
    f.name = "note_attachments[" + noteFileFieldCount + "][file]";
    f.size = 30;
    var d = document.createElement("input");
    d.type = "text";
    d.name = "note_attachments[" + noteFileFieldCount + "][description]";
    d.size = 60;

    p = document.getElementById("note_attachments_fields");
    p.appendChild(document.createElement("br"));
    p.appendChild(f);
    p.appendChild(d);
}
  
function removeField(link) {
	Effect.Fade($(link).up(),{duration:0.5}); 
	$(link).previous().value = '';
}

function addField(link, content) {
	$(link).up().insert({
		before: content
	})    
}