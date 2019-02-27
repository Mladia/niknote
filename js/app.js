let max_rows = 15;
let c_note_id = 0;
var notes = [];
let notes_html = [];

function Note(title){
    this.id = get_first_free_id();
    this.title = title;
    this.text = 'Lorem ipsum te';
    this.tags = [ 'lo', 're'];
    this.done = false;

    this.snoozed = false;
    this.snoozed_time = "";
    this.snoozed_date = "";


    this.describe = function(){
        return 'Note:' + this.id + ', title:' + 
            this.title + ', done:' + done +
            ', tags: -' + this.tags +
            '-, text:' + this.text; 
    }

    this.delete = function(){
        let return_next = false;
        console.log("Deleting " + c_note_id);
        notes.splice(notes.indexOf(this), 1);
        while (notes[c_note_id] == null) {
            console.log("trying:" + c_note_id);
            if (is_empty()){
                return;
            }
            c_note_id = mod(c_note_id+1, notes.length);
        }
    }

    this.set_done = function(){
        if (is_empty()){
            return;
        }
        this.done = true;
        this.delete();
    }

    this.delete_note = function(){
        if (is_empty()){
            return;
        }
        // notes.splice( notes.indexOf(this), 1 );
        console.log("1Deleting " + c_note_id);
    }
    
    this.snooze = function (time, date)  {
        this.snoozed = true;
        this.snoozed_time = time;
        this.snoozed_date = date;
        console.log("Snoozing for " + time + ", " + date );
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

function c_note_done(){
    console.log('Setting current note as done!');
    notes[c_note_id].set_done();   
    print_notes();
}

function c_note_delete(){
    console.log("Deleting " + c_note_id);
    notes[c_note_id].delete();
    go_back_note();
    // print_notes();
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

Date.prototype.toDateInputValue = (function() {
    var local = new Date(this);
    local.setMinutes(this.getMinutes() - this.getTimezoneOffset());
    return local.toJSON().slice(0,10);
});

// var ex_note = new Note('0 note');
// ex_note.text="Korem";
// notes.push(ex_note); 
// var ex_note = new Note('1 note');
// notes.push(ex_note); 
// var ex_note = new Note('2 note');
// notes.push(ex_note); 
// var ex_note = new Note('3 note');
// notes.push(ex_note); 
var ex_note = new Note('4 note');
notes.push(ex_note); 
var ex_note = new Note('5 note');
notes.push(ex_note); 
// var stringObj = JSON.stringify(notes);
// console.log(stringObj);
// pull_notes();
// loadDoc();

function pull_notes() {

    $.ajax({
        url: "/server.php",
        async: false,
        type: "POST",
        header: {'Access-Control-Allow-Origin': '*'},
        dataType: "json",
        data: "cmd=get_notes",
        success: function (result) {
            console.log(result);
            console.log("YE!");
            $('#demo').innerHTML = "YE!";
            notes = JSON.parse(result);
            print_notes();
        },
        error: function (xhr, ajaxOptions, thrownError) {
            console.log("NO!");
            console.log(xhr);
            console.log(thrownError);
        }
        });    


    print_notes();
}

function push_notes() {

    let stringObj = JSON.stringify(notes);
    let data = '{"cmd":"push_notes","notes":' + stringObj + '}';
    console.log(data);
    $.ajax({
        url: "/server.php",
        async: false,
        type: "POST",
        header: {'Access-Control-Allow-Origin': '*'},
        dataType: "json",
        contentType: "application/json",
        data: data, 
        contentType: 'application/json',
        success: function (result) {
            console.log("YE!");
            console.log(result);
            // notes = JSON.parse(result);
            // print_notes();
        },
        error: function (xhr, ajaxOptions, thrownError) {
            console.log(xhr);
            console.log("NO!");
            console.log(thrownError);
        }
        });    
}