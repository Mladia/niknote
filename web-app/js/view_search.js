max_rows = 40;
var new_image = false;
var image_to_upload;
var search_term = ""
var show_notes = [];

function print_notes() {
    //set current note
    show_notes = [];
    show_notes = get_searched_notes(search_term);
    
    console.log("Current note is " + c_note_id + ",length:" + show_notes.length);

    //remove old notes
    for (i in notes_html){
      notes_html[i].remove();
    }

    image_to_upload = "";
    if (show_notes[0] == null || show_notes.length == 0) {
        $('#currentNoteTitle').text("  ");
        $('#currentNoteBox').find('p').text("  No notes found.");
        $('#currentNoteTags').text("");
        return;
    }

   
    if (show_notes[c_note_id] == null){
        console.log("current note is null");
        c_note_id = mod(c_note_id+1, notes.length);
        print_notes();
        return;
    }


    if (! show_notes[c_note_id].image) {
        $('#currentNoteImageDiv').hide()
    } else {
        load_current_image();
        console.log("Showing image also!");
        $('#currentNoteImageDiv').show();
    }

    $('#currentNoteTitle').text(show_notes[c_note_id].title);
    $('#currentNoteBox').find('p').text(show_notes[c_note_id].text);
    $('#currentNoteTags').text(show_notes[c_note_id].tags);
    //colors for done/snoozed
    if (show_notes[c_note_id].done) {
        $('#currentNoteTitle').css('text-decoration', 'line-through')
        $('#currentNoteTitle').css("color", "green");
        $('#c_done_button').hide();
        $('#c_snooze_button').hide();
        $('#c_change_button').hide();
    } else if (show_notes[c_note_id].snoozed) {
        $('#currentNoteTitle').css("color", "orange");
        $('#currentNoteTitle').css('text-decoration', 'none')
        $('#c_done_button').show();
        $('#c_snooze_button').show();
        $('#c_change_button').show();
        $('#currentNoteTitle').text(show_notes[c_note_id].title +
            "; Snoozed untill " + 
        // $('#currentNoteBox').find('p').text( "Snoozed for " + 
            show_notes[c_note_id].snoozed_time + " on " +
            show_notes[c_note_id].snoozed_date );
    } else {
        $('#c_done_button').show();
        $('#c_snooze_button').show();
        $('#c_change_button').show();
        $('#currentNoteTitle').css("color", "black");
        $('#currentNoteTitle').css('text-decoration', 'none')
    }

    let rows = ( (max_rows > show_notes.length) ? show_notes.length : max_rows);
    let show_id = 0;
    for (i = 1; i <= rows; i++){

        if (show_id == c_note_id) {
            show_id =  mod( (show_id + 1),  show_notes.length ) ;
            continue;
        }

        let new_div = document.createElement('div');
        new_div.setAttribute('onclick','change_current(' + show_id + ')' );
        new_div.className = "noteContainer";
        new_div.innerText = show_notes[show_id].title;
        notes_html.push(new_div);
        if (show_notes[show_id].done) {
            new_div.style.color = "green";
            new_div.style.textDecoration = "line-through";
        } else if (show_notes[show_id].snoozed) {
            new_div.style.color = "orange";
            new_div.style.textDecoration = "none";
        } else {
            new_div.style.color = "black";
            new_div.style.textDecoration = "none";
        }

        let new_div_inner = document.createElement('div');
        new_div_inner.className = "noteContainerTags";
        new_div_inner.innerText = show_notes[show_id].tags;
        
        let big_container = document.getElementById('bigContainer');
        big_container.appendChild(new_div);

        new_div.appendChild(new_div_inner);
       

        show_id =  mod( (show_id + 1),  show_notes.length ) ;
    }
}


function go_back_note() {
    do {
        c_note_id = mod(c_note_id-1, notes.length);
    } while (notes[c_note_id] == null);
    print_notes();
}
function go_for_note() {
    do {
        c_note_id = mod(c_note_id+1, notes.length);
    } while (notes[c_note_id] == null);
    print_notes();
}

const newNoteModal = document.getElementById("newNoteModal");
const changeNoteModal = document.getElementById("changeNoteModal")
const snoozeModal = document.getElementById("snoozeModal")
const closeBtnNew = document.getElementById("closeBtnNew");
const closeBtnChange = document.getElementById("closeBtnChange");
const closeBtnSnooze = document.getElementById("closeBtnSnooze");



function delete_new_image (){
    $("#changeImageBlock").hide();
    $('#changePhotoLabel').show();
    image_to_upload = ""
}

//#########
function show_change_note_modal() {
    if(is_empty() || notes[c_note_id].done){
        return;
    }
    $('#changeOK').hide();
    if(notes[c_note_id].image){
        console.log("image");
        //no photo, take picture
        reload_current();
        $("#changeImageBlock").show();
        $('#changePhotoLabel').hide();
        $('#imageChangeIMG').show();
        $('#deleteImageNew').show();
    } else {
        $('#changeImageBlock').hide();
    }
    changeNoteModal.style.display = 'block';
}

function show_photo_change_dialog (){
    //load current
    $('#changePhotoLabel').hide();
    // $('#changeImageBlock').css("display", "none");
    $('#changeImageBlock').show();
    $('#imageChangeIMG').show();
    $('#deleteImageNew').show();
}

function show_loaded_imageOK () {
    $('#changeImageBlock').show();
    $('#changeOK').show();
    $('#imageChangeIMG').hide();
    $('#deleteImageNew').hide();
    $('#changePhotoLabel').hide();
    // $('#changeImageBlock').css("display", "initial");
}

closeBtnNew.addEventListener("click", close_note_modal);
closeBtnChange.addEventListener("click", close_note_modal);
closeBtnSnooze.addEventListener("click", close_note_modal);
function close_note_modal() {
    newNoteModal.style.display = 'none';
    changeNoteModal.style.display = 'none';
    snoozeModal.style.display = 'none';
    $("#takePhotoNew").show();
    $("#imageBlockNew").css("display", "none") ;
    $('#changeImageBlock').hide();
    $('#changePhotoLabel').show();
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
        // alert("Cannot save a note with an empty title");
        return;
    }
    var new_note = new Note(new_note_title);
    
    new_note.text = new_note_text_field.value; 
    new_note.tags = new_note_tags_field.value.split(",");
    insert_new_note(new_note);
    c_note_id = new_note.id;
    if (image_to_upload != "") {
        sendFile(c_note_id, image_to_upload);
        notes[c_note_id].image = true;
        image_to_upload = "";
    }
    close_note_modal();
    new_note_title_field.value = "";
    new_note_tags_field.value = "";
    new_note_text_field.text = "";
    reload_current();
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
    current_note.tags = new_note_tags_field.value.split(",");

     if (image_to_upload != "") {
        sendFile(c_note_id, image_to_upload);
        notes[c_note_id].image = true;
        image_to_upload = "";
    } else if (notes[c_note_id].image && image_to_upload == "") {
        notes[c_note_id].image = false;
        image_to_upload = "";
    }else {
        notes[c_note_id].image = false;
    }
    
    close_note_modal();
    new_note_title_field.value = "";
    new_note_tags_field.value = "";
    new_note_text_field.text = "";
}


function c_note_done(){
    console.log('Setting current note as done!');
    // notes[c_note_id].set_done();   
    set_done(c_note_id);
    print_notes();
    push_notes();
}





var timeControl;
var dateControl;

function c_note_snooze() {
    show_snooze_modal();
}

function show_snooze_modal() {
    snoozeModal.style.display = 'block';
    //set current date
    let today = new Date();
    let currentDate = today.toDateInputValue();
    $('#snoozeDate').val(currentDate);
    c_note_id = find_orig_note();

}

function snoozeMorn(){
    console.log("Snoozing morning");
    timeControl = "09:00";
    dateControl = $('#snoozeDate').val();
    finishSnooze();
}
function snoozeAft(){
    console.log("Snoozing aft");
    timeControl = "14:00";
    dateControl = $('#snoozeDate').val();
    console.log("date: " + dateControl);
    finishSnooze();
}
function snoozeEve(){
    console.log("Snoozing evening");
    timeControl = "18:00";
    dateControl = $('#snoozeDate').val();
    finishSnooze();
}
function snoozeCustom(){
    console.log("Snoozing custom");
    timeControl = $("#snoozeTime").val();
    dateControl = $('#snoozeDate').val();
    finishSnooze();
}

function finishSnooze() {
    let today = new Date();
    let currentDate = today.toDateInputValue();
    let curretTime = today.getHours() + ":" + today.getMinutes();
    console.log("Trying to snooze " + timeControl + ", and " + dateControl);
    //is date valid
    if (dateControl < currentDate) {
        alert("Date is not valid");
        return;
    }
    
    if (dateControl == currentDate 
        && timeControl < curretTime){
            alert("Time traveler alert! Cannot set a reminder in the past!");
            return;
    }
    let is_valid = /^([0-1][0-9]|2[0-3]):([0-5][0-9])$/.test(timeControl);
    if (! is_valid){
        alert("Time not valid");
        return;
    }

    close_note_modal();
    snooze(c_note_id, timeControl, dateControl);
    close_note_modal();
}

const searchBar = document.forms['searchBox'].querySelector('input');
searchBar.addEventListener("keyup", function(e){
    const term = e.target.value.toLowerCase();
    search_term = term;
    print_notes();
})

function get_searched_notes(term){
    let alter_notes = [];
    notes.forEach(function(note, index, array) {
        let added = false;
        if (note.title.toLowerCase().includes(term)) {
            added = true;
        }

        if (note.text.toLowerCase().includes(term)) {
            added = true;
        }

        note.tags.forEach(function(tag, index1, array1) {
            if (tag.toLowerCase().includes(term)) {
                added = true;
            }
        });

        if (added) {
             alter_notes.push(note);
        }
    });
    return alter_notes;
}

function c_note_done(){
    c_note_id = find_orig_note();
    console.log("Setting " + c_note_id + " current note as done!");
    set_done(c_note_id);
    print_notes();
    push_notes();
}

function find_orig_note() {
    let suspect = null
    let found = null;

    searching = show_notes[c_note_id];
    for (let i = 0; i < notes.length; i++) {
        let orig_note = notes[i];
        if (orig_note == null){
            continue;
        }
        //no logic here...
        if (searching.title.localeCompare(orig_note.title))  {
            continue;
        }

        if (searching.text.localeCompare(orig_note.text)) {
            continue;
        }
        return i;
    }
}