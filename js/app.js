
let c_note_id = 0;
let notes = [];
let notes_archived = [];

function Note(title){
    this.id = get_first_free_id();
    this.title = title;
    this.text = 'Lorem ipsum te';
    this.tags = [ 'le', 're'];
    var done = false;

    this.describe = function(){
        return 'Note:' + this.id + ', title:' + 
            this.title + ', done:' + done +
            ', tags: -' + this.tags +
            '-, text:' + this.text; 
    }

    this.set_done = function(){
        done = true;
    }
}

function get_first_free_id(){
    return notes.length
}

function c_note_done(){
    notes[c_note_id].set_done();   
    console.log('Setting current note as done!');
}

function create_note(title) {
    var new_note = new Note(title); 
    insert_new_note(new_note);
}
function insert_new_note(new_note) {
    notes.push(new_note);
}


function go_back_note() {
    console.log("Going back");
}
function go_for_note() {
    console.log("Going forward");
    c_note_id = (c_note_id+1) % notes.length;
}

var ex_note = new Note('First note');
create_note("Eyo");
create_note("Hayo");
create_note("Buyo");
notes.push(ex_note); 
console.log(ex_note.describe());
