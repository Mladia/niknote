let max_rows = 15;
let c_note_id = 0;
var notes = [];
var notes_archived = [];
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
        this.done = true;
        notes_archived.push(this);
        notes.splice( notes.indexOf(this), 1 );
    }

    this.delete = function(){
        notes.splice( notes.indexOf(this), 1 );
    }
}

function mod(n, m) {
  return ((n % m) + m) % m;
}
function get_first_free_id(){
    return notes.length;
}

function c_note_done(){
    console.log('Setting current note as done!');
    notes[c_note_id].set_done();   
    print_notes();
}

function c_note_delete(){
    console.log("Deleting " + c_note_id);
    notes[c_note_id].delete();
    print_notes();
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

function change_current(id){
    console.log("Changing with " + id);
    c_note_id = id;
    print_notes();
}

var ex_note = new Note('0 note');
ex_note.text="Korem";
notes.push(ex_note); 
var ex_note = new Note('1 note');
notes.push(ex_note); 
var ex_note = new Note('2 note');
notes.push(ex_note); 
var ex_note = new Note('3 note');
notes.push(ex_note); 
var ex_note = new Note('4 note');
notes.push(ex_note); 
var ex_note = new Note('5 note');
notes.push(ex_note); 
print_notes();




function print_notes() {
    //set current note
    if (notes[0] == null){
        $('#currentNoteTitle').text("  ");
        $('#currentNoteBox').find('p').text("  No notes saved. Your new note will appear here..");
        $('#currentNoteTags').text("");

        return;
    }

    //remove old notes
    for (i in notes_html){
      notes_html[i].remove();
    }
   

    $('#currentNoteTitle').text(notes[c_note_id].title);
    $('#currentNoteBox').find('p').text(notes[c_note_id].text);
    $('#currentNoteTags').text(notes[c_note_id].tags);

    let rows = ( (max_rows > notes.length) ? notes.length : max_rows);
    let limit_before = 2;
    let show_id = 0;
    show_id = mod( (c_note_id - limit_before) , notes.length);
    for (i = 1; i <= rows; i++){

        if (show_id == c_note_id){
            show_id = mod( (show_id + 1), notes.length );
            continue;
        }

        let new_div = document.createElement('div');
        new_div.setAttribute('onclick','change_current(' + show_id + ')' );
        new_div.className = "noteContainer";
        new_div.innerText = notes[show_id].title;
        notes_html.push(new_div);

        let new_div_inner = document.createElement('div');
        new_div_inner.className = "noteContainerTags";
        new_div_inner.innerText = notes[show_id].tags;
        
        if (i <= limit_before){
            let c_note_before = document.getElementById('notesBefore');
            c_note_before.appendChild(new_div);
        } else {
            let big_container = document.getElementById('bigContainer');
            big_container.appendChild(new_div);
        }

        new_div.appendChild(new_div_inner);
        
        show_id =  mod( (show_id + 1),  notes.length ) ;
    }
}

var newNoteModal = document.getElementById("newNoteModal");
var changeNoteModal = document.getElementById("changeNoteModal")
var closeBtnNew = document.getElementById("closeBtnNew");
var closeBtnChange = document.getElementById("closeBtnChange");

function show_new_note_modal() {
    newNoteModal.style.display = 'block';
}

function show_change_note_modal() {
    changeNoteModal.style.display = 'block';
}

closeBtnNew.addEventListener("click", close_note_modal);
closeBtnChange.addEventListener("click", close_note_modal);
function close_note_modal() {
    newNoteModal.style.display = 'none';
    changeNoteModal.style.display = 'none';
    print_notes();
}

window.addEventListener('click', call_outside);
function call_outside(e){
    if (e.target == newNoteModal || 
        e.target == changeNoteModal){
        close_note_modal();
    }
}

function save_new_note(){
    console.log("Save new note button");
    let new_note_title = "";
    let tags = [];

    let new_note_title_field = document.getElementById("newNoteTitle");
    let new_note_tags_field = document.getElementById("newNoteTags");
    let new_note_text_field = document.getElementById("newNoteText");

    new_note_title = new_note_title_field.value; 
    if (new_note_title == "") {
        // alert("Canno save a note with an empty title");
        return;
    }
    var new_note = new Note(new_note_title);
    
    new_note.text = new_note_text_field.value; 
    new_note.tags = new_note_tags_field.value;
    insert_new_note(new_note);
    c_note_id = new_note.id;
    
    close_note_modal();
    new_note_title_field.value = "";
    new_note_tags_field.value = "";
    new_note_text_field.text = "";
}

function c_note_change(){
    show_change_note_modal();

    let note_title_field = document.getElementById("changeNoteTitle");
    let note_tags_field = document.getElementById("changeNoteTags");
    let note_text_field = document.getElementById("changeNoteText");

    note_title_field.value = notes[c_note_id].title;
    note_tags_field.value = notes[c_note_id].tags;
    note_text_field.value = notes[c_note_id].text;

    
}

function save_changed_note(){
    console.log("Save change note button");
    let new_note_title = "";
    let tags = [];

    let new_note_title_field = document.getElementById("changeNoteTitle");
    let new_note_tags_field = document.getElementById("changeNoteTags");
    let new_note_text_field = document.getElementById("changeNoteText");

    new_note_title = new_note_title_field.value; 
    if (new_note_title == "") {
        // alert("Canno save a note with an empty title");
        return;
    }
    let current_note = notes[c_note_id];
    
    current_note.title = new_note_title_field.value;
    current_note.text = new_note_text_field.value; 
    current_note.tags = new_note_tags_field.value;
    
    close_note_modal();
    new_note_title_field.value = "";
    new_note_tags_field.value = "";
    new_note_text_field.text = "";
}