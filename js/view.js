
function print_notes() {
    console.log("Current note is " + c_note_id + ",length:" + notes.length);
    //set current note

    if (notes[0] == null || notes.length == 0) {
        $('#currentNoteTitle').text("  ");
        $('#currentNoteBox').find('p').text("  No notes saved. Your new note will appear here..");
        $('#currentNoteTags').text("");
        return;
    }

    if (notes[c_note_id].snoozed
        || notes[c_note_id].done) {
        c_note_id = mod(c_note_id+1, notes.length);
    }


    //remove old notes
    for (i in notes_html){
      notes_html[i].remove();
    }
   
    if (notes[c_note_id] == null){
        console.log("current note is null");
        c_note_id = mod(c_note_id+1, notes.length);
        print_notes();
    }

    $('#currentNoteTitle').text(notes[c_note_id].title);
    $('#currentNoteBox').find('p').text(notes[c_note_id].text);
    $('#currentNoteTags').text(notes[c_note_id].tags);

    let rows = ( (max_rows > notes.length) ? notes.length : max_rows);
    let limit_before = 2;
    let show_id = 0;
    show_id = mod( (c_note_id - limit_before) , notes.length);
    for (i = 1; i <= rows; i++){

        if (notes[show_id].snoozed
            || notes[show_id].done
            || show_id == c_note_id){
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
var snoozeModal = document.getElementById("snoozeModal")
var closeBtnNew = document.getElementById("closeBtnNew");
var closeBtnChange = document.getElementById("closeBtnChange");
var closeBtnSnooze = document.getElementById("closeBtnSnooze");

function show_new_note_modal() {
    newNoteModal.style.display = 'block';
}

function show_change_note_modal() {
    if(notes.length == 0 ){
        return;
    }
    changeNoteModal.style.display = 'block';
}

closeBtnNew.addEventListener("click", close_note_modal);
closeBtnChange.addEventListener("click", close_note_modal);
closeBtnSnooze.addEventListener("click", close_note_modal);
function close_note_modal() {
    newNoteModal.style.display = 'none';
    changeNoteModal.style.display = 'none';
    snoozeModal.style.display = 'none';
    print_notes();
}

window.addEventListener('click', call_outside);
function call_outside(e){
    if (e.target == newNoteModal || 
        e.target == changeNoteModal ||
        e.target == snoozeModal){
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

function c_note_snooze() {
    show_snooze_modal();
}

function show_snooze_modal() {
    snoozeModal.style.display = 'block';
    $('#snoozeDate').val(new Date().toDateInputValue());
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


function snoozeMorn(){
    console.log("Snoozing morning");
    let timeControl = "09:00";
    //TODO:
    let dateControl = document.getElementById('#snoozeDate').value;
    // let dateControl = $('#snoozeDate').value;
    // new Date().toDateInputValue()
    snooze(c_note_id, timeControl, dateControl);
    close_note_modal();
}
function snoozeAft(){
    console.log("Snoozing aft");
    let timeControl = "14:00";
    let dateControl = $('#snoozeDate').value;
    snooze(c_note_id, timeControl, dateControl);
    close_note_modal();
}
function snoozeEve(){
    console.log("Snoozing evening");
    let timeControl = "18:00";
    let dateControl = $('#snoozeDate').value;
    snooze(c_note_id, timeControl, dateControl);
    close_note_modal();
}
function snoozeCustom(){
    console.log("Snoozing custom");
    let timeControl = document.getElementById("snoozeTime");
    console.log("Snoozing for " + timeControl.value);
    let is_valid = /^([0-1][0-9]|2[0-3]):([0-5][0-9])$/.test(timeControl.value);
    if (is_valid){
        close_note_modal();
        snooze(c_note_id, timeControl, dateControl);
    }
}