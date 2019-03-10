var c_note_id = 0;
let max_rows = 40;
var notes = [];


function Note(title){
    this.id = get_first_free_id();
    this.title = title;
    this.text = 'Lorem ipsum te';
    this.tags = [ 'lo', 're'];
    var done = false;

    this.describe = function(){
        return 'Note:' + this.id + ', title:' + 
            this.title + ', done:' + done +
            ', tags: -' + this.tags +
            '-, text:' + this.text; 
    }

    this.delete = function(){
        notes.splice( notes.indexOf(this), 1 );
    }
}

var ex_note = new Note('First note');
ex_note.text="Korem";
notes.push(ex_note); 
var ex_note = new Note('Second note');
notes.push(ex_note); 
var ex_note = new Note('Third note');
notes.push(ex_note); 
print_notes();

function c_arch_del(){
    //deleting archived
}


function print_notes() {
    //set current note
    if (notes[0] != null){
        $('#currentNoteTitle').text(notes[c_note_id].title);
        $('#currentNoteBox').find('p').text(notes[c_note_id].text);
        $('#currentNoteTags').text(notes[c_note_id].tags);
    } else {
        $('#currentNoteTitle').text("\n");
        $('#currentNoteBox').find('p').text("\n");
    }

    //remove old notes
    for (i in notes_html){
      notes_html[i].remove();
    }
    
    let rows = ( (max_rows > notes.length) ? notes.length : max_rows);
    let show_id = c_note_id;
    for (i = 0; i < rows; i++){
        if (show_id == c_note_id){
            show_id = (show_id + 1 + i) % notes.length;
            continue;
        }

        let new_div = document.createElement('div');
        notes_html.push(new_div);
        new_div.className = "noteContainer";
        new_div.innerText = notes[show_id].title;

        let new_div_inner = document.createElement('div');
        new_div_inner.className = "noteContainerTags";
        new_div_inner.innerText = notes[show_id].tags;
        
        let big_container = document.getElementById('bigContainer');
        big_container.appendChild(new_div);
        new_div.appendChild(new_div_inner);
        
        //show_id = mod(i+1, notes.length);
        show_id = (show_id + i) % notes.length;
    }
}