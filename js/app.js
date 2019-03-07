var c_note_id = 0;
var max_rows;
var notes = [];
var notes_html = [];
var c_image;

function Note(title){
    this.id = get_first_free_id();
    this.title = title;
    this.text = '';
    this.tags = [];
    this.done = false;

    this.snoozed = false;
    this.snoozed_time = "";
    this.snoozed_date = "";

    this.image = false;

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
    notes[id].image = false;
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
// ex_note.tags="[Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?".split(",");
notes.push(ex_note); 
var ex_note = new Note('1 note');
// ex_note.image = true;
ex_note.tags = ["ho", "ma"];
notes.push(ex_note); 
var ex_note = new Note('2 note');
ex_note.tags = ['baby', 'person'];
notes.push(ex_note); 
var ex_note = new Note('3 note');
notes.push(ex_note); 
var ex_note = new Note('4 note');
ex_note.tags = ['ba'];
// ex_note.image = true;
notes.push(ex_note); 
var ex_note = new Note('5 note');
notes.push(ex_note); 
c_note_id = 1;
pull_notes();
print_notes();


function pull_notes() {
    // return;
    console.log("Pulling notes request");
    $.ajax({
        url: "/server.php",
        async: false,
        type: "POST",
        header: {'Access-Control-Allow-Origin': '*'},
        data: "cmd=get_notes",
        success: function (result) {
            console.log("Pulling notes completed!");
            notes = result;
        },
        error: function (xhr, ajaxOptions, thrownError) {
            console.log("Pullung notes ERROR!");
            console.log(xhr);
            console.log(thrownError);
        },
        contentType: 'application/x-www-form-urlencoded',
        dataType: 'json',
        });    

    print_notes();
}

function push_notes() {
    // return;

    let data = JSON.stringify({
        cmd : "push_notes",
        notes : notes 
    });
    console.log("Pushing notes request")
    $.ajax({
        url: "server.php",
        async: true,
        type: "POST",
        header: {'Access-Control-Allow-Origin': '*'},
        dataType: "json",
        // data: JSON.stringify(data), 
        data: data, 
        contentType: 'application/json',
        success: function (result) {
            console.log("Pushing notes completed!");
        },
        error: function (xhr, ajaxOptions, thrownError) {
            console.log(xhr);
            console.log("Pushing notes ERROR!");
            console.log(thrownError);
        }
        });    
}

//checking file input
if (window.File && window.FileReader && window.FormData) {
	var $inputField = $('#photoNew');
	$inputField.on('change', function (e) {
		var file = e.target.files[0];

		if (file) {
			if (/^image\//i.test(file.type)) {
				readFile(file);
			} else {
				alert('Not a valid image!');
            }
            
            if (file.size > 100*1000000) {
                alert("File is too big!");
            }
        }
        console.log("Size: " + file.size);
	});
} else {
	alert("File upload is not supported!");
}

function readFile(file) {
    console.log("Reading file");
	var reader = new FileReader();

	reader.onloadend = function () {
		processFile(reader.result, file.type);
	}

	reader.onerror = function () {
		alert('There was an error reading the file!');
	}

	reader.readAsDataURL(file);
}




function processFile(dataURL, fileType) {

	var image = new Image();
	image.src = dataURL;

	image.onload = function () {
        new_image = true;
        image_to_upload = dataURL;
        //show imageBlock
        show_photo_new_dialog();
	};

	image.onerror = function () {
		alert('There was an error processing your file!');
	};
}


//checking file input CHANGE
if (window.File && window.FileReader && window.FormData) {
	var $inputField = $('#photoChange');
	$inputField.on('change', function (e) {
		var file = e.target.files[0];

		if (file) {
			if (/^image\//i.test(file.type)) {
				readFileChange(file);
			} else {
				alert('Not a valid image!');
            }
            
            if (file.size > 100*1000000) {
                alert("File is too big!");
            }
        }
        console.log("Size: " + file.size);
	});
} else {
	alert("File upload is not supported!");
}

function readFileChange(file) {
    console.log("Reading file");
	var reader = new FileReader();

	reader.onloadend = function () {
		processFileChange(reader.result, file.type);
	}

	reader.onerror = function () {
		alert('There was an error reading the file!');
	}

	reader.readAsDataURL(file);
}


function processFileChange(dataURL, fileType) {

	var image = new Image();
	image.src = dataURL;

	image.onload = function () {
        image_to_upload = dataURL;
        show_loaded_imageOK();
	};

	image.onerror = function () {
		alert('There was an error processing your file!');
	};
}

function sendFile(id, fileData) {
    console.log("Sending file request");
	var formData = new FormData();

    formData.append('push', "yes");
    formData.append('id', id);
    formData.append('imageData', fileData);
    
    // return;
	$.ajax({
		type: 'POST',
		url: '/server.php',
        data: formData, 
        async: true,
		contentType: false,
        processData: false,
        dataType: "json",
		success: function (data) {
			if (data.success) {
                // alert('Your file was successfully uploaded!');
                console.log("Sending image request completed");
                load_current_image();
			} else {
                console.log(data);
				alert('There was an ERROR sending your image!');
			}
		},
		error: function (data) {
            console.log(data);
			alert('There was an error sending your image2!');
		}
    });
    
    new_image = false;
    image_to_upload = "";
}


function load_current_image() {
    //set image to current
    console.log("Loading current image request");
    let s_data = JSON.stringify( 
        {update_current : c_note_id}
    );
    
    $.ajax({
        url: "server.php",
        async: true,
        type: "POST",
        header: {'Access-Control-Allow-Origin': '*'},
        dataType: "json",
        contentType: 'application/json',	
        data: s_data, 
        success: function (result) {
            if (result.success) {
                console.log("Loading current image success!");
                if (notes[c_note_id].image){
                    let url = "images/current.jpeg?rnd="+Math.random();
                    $('#currentNoteImage').attr("src", url);
                }
            } else {
                console.log("result");
                console.log("Loading current image ERROR1!");
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            console.log(xhr);
            console.log("Loading current image ERROR2!");
            console.log(thrownError);
        }
        });      
}