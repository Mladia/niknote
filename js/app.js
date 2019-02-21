let max_rows = 15;
let c_note_id = 0;
let notes = [];
let notes_archived = [];
let notes_html = [];

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

    this.set_done = function(){
        done = true;
        notes_archived.push(this);
        notes.splice( notes.indexOf(this), 1 );
    }
}

function get_first_free_id(){
    return notes.length
}

function c_note_done(){
    console.log('Setting current note as done!');
    notes[c_note_id].set_done();   
    print_notes();
}

function create_note(title) {
    var new_note = new Note(title); 
    insert_new_note(new_note);
}
function insert_new_note(new_note) {
    notes.push(new_note);
}


function go_back_note() {
    c_note_id = mod(c_note_id-1, notes.length);
    print_notes();
}
function go_for_note() {
    c_note_id = mod(c_note_id+1, notes.length);
    print_notes();
}

var ex_note = new Note('First note');
ex_note.text="Korem";
notes.push(ex_note); 
var ex_note = new Note('Second note');
notes.push(ex_note); 
var ex_note = new Note('Third note');
notes.push(ex_note); 
print_notes();




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
    
    var rows = ( (max_rows > notes.length) ? notes.length : max_rows);
    var show_id = c_note_id;
    for (i = 0; i < rows; i++){
        if (show_id == c_note_id){
            show_id = (show_id + 1 + i) % notes.length;
            continue;
        }

        var new_div = document.createElement('div');
        notes_html.push(new_div);
        new_div.className = "noteContainer";
        new_div.innerText = notes[show_id].title;

        var new_div_inner = document.createElement('div');
        new_div_inner.className = "noteContainerTags";
        new_div_inner.innerText = notes[show_id].tags;
        
        var big_container = document.getElementById('bigContainer');
        big_container.appendChild(new_div);
        new_div.appendChild(new_div_inner);
        
        //show_id = mod(i+1, notes.length);
        show_id = (show_id + i) % notes.length;
    }
}


function mod(n, m) {
  return ((n % m) + m) % m;
}
