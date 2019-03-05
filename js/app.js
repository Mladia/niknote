let c_note_id = 0;
var max_rows;
var notes = [];
let notes_html = [];

function Note(title){
    this.id = get_first_free_id();
    this.title = title;
    this.text = '\n';
    this.tags = [];
    this.done = false;

    this.snoozed = false;
    this.snoozed_time = "";
    this.snoozed_date = "";

    this.picture_name = "";

    this.describe = function(){
        return 'Note:' + this.id + ', title:' + 
            this.title + ', done:' + this.done +
            ', tags: -' + this.tags +
            '-, text:' + this.text; 
    }

}

function set_done(id) {
    if (is_empty()){
        return;
    }
    console.log("Setting " + id + " as node");
    notes[id].done = true;
    notes[id].snoozed = false;
}

function delete_note(id) {
    if (is_empty()){
        return;
    }
    // notes.splice( notes[id], 1 );
    console.log("1Deleting " + c_note_id);
    delet(id);
}

function delet(id) {
    let return_next = false;
    console.log("Deleting " + c_note_id);
    notes.splice(id, 1);
    while (notes[c_note_id] == null) {
        console.log("trying:" + c_note_id);
        if (is_empty()){
            return;
        }
        c_note_id = mod(c_note_id+1, notes.length);
    }
}

function is_empty() {
    return notes.length == 0;
}

function mod(n, m) {
  return ((n % m) + m) % m;
}
function get_first_free_id(){
    return notes.length;
}

function snooze (id, time, date) {
    notes[id].snoozed = true;
    notes[id].snoozed_time = time;
    notes[id].snoozed_date = date;
    console.log("Snoozing for " + time + ", " + date );
    push_notes();
}


function c_note_delete(){
    console.log("Deleting " + c_note_id);
    // notes[c_note_id].delete();
    delet(c_note_id); 
    go_back_note();
    push_notes();
    // print_notes();
}

function insert_new_note(new_note) {
    notes.push(new_note);
    push_notes();
}


function change_current(id){
    console.log("Changing with " + id);
    c_note_id = id;
    print_notes();
}

Date.prototype.toDateInputValue = (function() {
    var local = new Date(this);
    local.setMinutes(this.getMinutes() - this.getTimezoneOffset());
    return local.toJSON().slice(0,10);
});

var ex_note = new Note('0 note');
ex_note.text="Korem";
notes.push(ex_note); 
var ex_note = new Note('1 note');
notes.push(ex_note); 
var ex_note = new Note('2 note');
ex_note.tags = ['baby', 'person'];
notes.push(ex_note); 
var ex_note = new Note('3 note');
notes.push(ex_note); 
var ex_note = new Note('4 note');
ex_note.tags = ['ba'];
notes.push(ex_note); 
var ex_note = new Note('5 note');
notes.push(ex_note); 
pull_notes();
print_notes();


function pull_notes() {
    return;
    $.ajax({
        url: "/server.php",
        async: false,
        type: "POST",
        header: {'Access-Control-Allow-Origin': '*'},
        data: "cmd=get_notes",
        success: function (result) {
            console.log(result);
            console.log("YE!");
            notes = result;
        },
        error: function (xhr, ajaxOptions, thrownError) {
            console.log("NO!");
            console.log(xhr);
            console.log(thrownError);
        },
        contentType: 'application/x-www-form-urlencoded',
        dataType: 'json',
        });    

    print_notes();
}

function push_notes() {
    return;

    let data = JSON.stringify({
        cmd : "push_notes",
        notes : notes 
    });
    console.log(data);
    $.ajax({
        url: "server.php",
        async: false,
        type: "POST",
        header: {'Access-Control-Allow-Origin': '*'},
        dataType: "json",
        // data: JSON.stringify(data), 
        data: data, 
        contentType: 'application/json',
        success: function (result) {
            console.log("YE!");
            console.log(result);
        },
        error: function (xhr, ajaxOptions, thrownError) {
            console.log(xhr);
            console.log("NO!");
            console.log(thrownError);
        }
        });    
}
