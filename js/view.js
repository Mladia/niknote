var new_image = false;
max_rows = 15;
var image_to_upload;


function print_notes() {
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
        return;
    }

    $('#currentNoteTitle').text(notes[c_note_id].title);
    $('#currentNoteBox').find('p').text(notes[c_note_id].text);
    $('#currentNoteTags').text(notes[c_note_id].tags);

    if (! notes[c_note_id].image) {
        $('#currentNoteImageDiv').hide()
    } else {
        load_current_image();
        console.log("Showing image also!");
        $('#currentNoteImageDiv').show();
    }

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


function go_back_note() {
    c_note_id = mod(c_note_id-1, notes.length);
    print_notes();
}
function go_for_note() {
    c_note_id = mod(c_note_id+1, notes.length);
    print_notes();
}
const newNoteModal = document.getElementById("newNoteModal");
const changeNoteModal = document.getElementById("changeNoteModal")
const snoozeModal = document.getElementById("snoozeModal")
const closeBtnNew = document.getElementById("closeBtnNew");
const closeBtnChange = document.getElementById("closeBtnChange");
const closeBtnSnooze = document.getElementById("closeBtnSnooze");

const takePhotoNew = $('#takePhotoNew');
const imageBlockNew = $('#newImageNote');
const deleteNewImage = $('deleteImageNew');


function show_photo_new_dialog() {
    console.log("Showing current ima");
    imageBlockNew.css("display", "initial") ;
    $('#newPhotoLabel').hide();
}


function delete_new_image (){
    $("#changeImageNote").css("display", "none") ;
    $('#changePhotoLabel').show();
    image_to_upload = ""
}

function show_new_note_modal() {
    newNoteModal.style.display = 'block';
    $('#newPhotoLabel').show();
}


function show_photo_change_dialog (){
    //load current
    $('#changeImageNote').hide();
    $('#changePhotoLabel').hide();
    $('#changeImageNote').css("display", "none");
    $('#changeOK').show();
}

function show_loaded_imageOK () {
    //TODO:
    $('#changePhotoLabel').hide();
    $('#imageChangeIMG').hide();
    $('#deleteImageNew').hide();
    $('#changeOK').show();
    // $('#changeImageNote').css("display", "initial");
}

function show_change_note_modal() {
    if(is_empty()){
        return;
    }
    $('#changeOK').hide();
    if(notes[c_note_id].image){
        console.log("image");
        //no photo, take picture
        // $('#newPhotoLabel').show();
        $('#changePhotoLabel').hide();
        $('imageChangeIMG').show();
        $('#changeImageNote').css("display", "initial");
        let url = "images/current.jpeg?rnd="+Math.random();
        $('#imageChangeIMG').attr("src", url);
    } else {
        console.log("no image");
        $('#changePhotoLabel').show();
        $('#changeImageNote').css("display", "none");
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
    takePhotoNew.show();
    imageBlockNew.css("display", "none") ;
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
    
    
    close_note_modal();
    new_note_title_field.value = "";
    new_note_tags_field.value = "";
    new_note_text_field.text = "";
    if (image_to_upload != "") {
        sendFile(c_note_id, image_to_upload);
        notes[c_note_id].image = true;
        image_to_upload = "";
    } else {
        notes[c_note_id].image = false;
    }
}


function c_note_done(){
    console.log('Setting current note as done!');
    // notes[c_note_id].set_done();   
    set_done(c_note_id);
    print_notes();
    push_notes();
}


//snooze
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
