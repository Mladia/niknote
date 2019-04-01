var new_image = false;
max_rows = 15;

function print_notes() {
    //set current note

    if (notes.length == 0) {
        $('#currentNoteTitle').text("  ");
        $('#currentNoteBox').find('p').text("  No notes saved. Your new note will appear here..");
        $('#currentNoteTags').text("");
        $('#currentNoteImageDiv').hide()
        return;
    }

    if (show_snoozed_notes()){
        return;
    }

    if (notes[c_note_id] == null){
        console.log("Current is null");
        go_for_note();
        return;
    }
    
    if (notes[c_note_id].snoozed
        || notes[c_note_id].done) {

         go_for_note();
        return;
    }

    //remove old notes
    for (i in notes_html){
      notes_html[i].remove();
    }
   
    image_to_upload = "";

    $('#currentNoteTitle').text(notes[c_note_id].title);
    $('#currentNoteBox').find('p').text(notes[c_note_id].text);
    $('#currentNoteTags').text(notes[c_note_id].tags);

    if (! notes[c_note_id].image) {
        $('#currentNoteImageDiv').hide()
    } else {
        load_current_image(c_note_id);
        console.log("Showing image also!");
        $('#currentNoteImageDiv').show();
    }

    let notes_length_abs = 0;
    for( let i = 0; i <notes.length; i++) {
        if (notes[i] == null || notes[i].done || notes[i].snoozed) {
            continue;
        }

        notes_length_abs++;
    }
    let rows = ( (max_rows > notes_length_abs) ? notes_length_abs : max_rows) -1 ;
    let limit_before = 2;
    let show_id = c_note_id;
    for (let i=0; i<limit_before; i++) {
        do {
            show_id = mod( (show_id - 1), notes.length );
        } while (notes[show_id] == null
            || notes[show_id].snoozed
            || notes[show_id].done );
    }
    for (let i = 1; i <= rows; i++){

        if (show_id == c_note_id) {
            // console.log("barrier");
            show_id = c_note_id + 1;
        }
        while (notes[show_id] == null || show_id == c_note_id) {
            // console.log("Show id is null");
            show_id = mod( (show_id + 1), notes.length );
        }

        
        if (notes[show_id].snoozed
            || notes[show_id].done){
            show_id = mod( (show_id + 1), notes.length );
            // console.log("ssnoozed or done");
            i = i-1;
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
    console.log("Go back note");
    if (notes.length == 0) {
        print_notes();
        return;
    }

    do {
        c_note_id = mod(c_note_id-1, notes.length);
    } while (notes[c_note_id] == null 
        || notes[c_note_id].done 
        || notes[c_note_id].snoozed);
    print_notes();
}
function go_for_note() {
    console.log("Go for note");
    if (notes.length == 0) {
        print_notes();
        return;
    }

    do {
        c_note_id = mod(c_note_id+1, notes.length);
    } while (notes[c_note_id] == null 
        || notes[c_note_id].done 
        || notes[c_note_id].snoozed);
    print_notes();
}
const newNoteModal = document.getElementById("newNoteModal");
const changeNoteModal = document.getElementById("changeNoteModal")
const snoozeModal = document.getElementById("snoozeModal")
const closeBtnNew = document.getElementById("closeBtnNew");
const closeBtnChange = document.getElementById("closeBtnChange");
const closeBtnSnooze = document.getElementById("closeBtnSnooze");

function show_new_note_modal() {
    newNoteModal.style.display = 'block';

    $('#newPhotoLabel').show();
    $('#newImageNote').hide();
}

function show_photo_new_dialog() {
    console.log("Showing current ima");
    $('#newImageNote').show();
    $('#newPhotoLabel').hide();
}

function delete_new_image (){
    $("#changeImageBlock").hide();
    $('#changePhotoLabel').show();
    image_to_upload = ""
}



//#########
function show_change_note_modal() {
    if(is_empty()){
        return;
    }
    $('#changeOK').hide();
    if(notes[c_note_id].image){
        console.log("image");
        //no photo, take picture
        reload_current(c_note_id);
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
    reload_current(c_note_id);
    push_notes();
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
        console.log("Retaining image")
        notes[c_note_id].image = true;
        image_to_upload = "";
    }else if ( (! notes[c_note_id].image) && image_to_upload =="" ) {
        console.log("no image whatsover");
        notes[c_note_id].image = false;
    }
    console.log("Closing");
    
    close_note_modal();
    new_note_title_field.value = "";
    new_note_tags_field.value = "";
    new_note_text_field.text = "";

    push_notes();
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

function c_note_delete(){
    note_delete(c_note_id);
}

function show_snoozed_notes() {

    if (unsnooze.length == 0) {
        $("#unsnoozeModel").css("display", "none");
        return;
    }
    
    console.log("Showing snoozed notes");

    let snoozed_tuple = unsnooze[unsnooze.length-1];
    let snoozed_id = snoozed_tuple.id;
    let snoozed_note = snoozed_tuple.note;
    let info_text = "Snoozed for ";
    info_text += snoozed_note.snoozed_date + ", " 
                                + snoozed_note.snoozed_time ;
                                
    c_note_id = snoozed_id;
    load_current_image(c_note_id);
    if (!snoozed_note.image) {
        $("#unsnoozedNoteImage").hide();
    } else {
        $("#unsnoozedNoteImage").show();
    }
    $("#infoSnooze").text(info_text);
    $("#unsnoozedTitle").text(snoozed_note.title);
    $("#unsnoozedTags").text(snoozed_note.tags);
    $("#unsnoozedText").text(snoozed_note.text);
    

    $("#unsnoozeModel").css("display", "block");

    return true;
}


$( "#unsnooze_ok" ).click(function() {
    console.log("Unsnoozing note");
    let snooze_id = unsnooze.pop().id;
    notes[snooze_id].snoozed = false;
    notes[snooze_id].snoozed_date = "";
    notes[snooze_id].snoozed_time = "";
    $("#unsnoozeModel").css("display", "none");
    push_notes();
    print_notes();
});
