var c_note_id = 0;
var max_rows;
var notes = [];
var notes_html = [];
var unsnooze = [];
var image_to_upload;


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
    push_notes();
}

function set_undone(id) {
    notes[id].done = false;
    push_notes();
}


function delet(id) {
    console.log("Deleting " + c_note_id);
    notes[id]=null;
    clean_up_last();
    return;

    //notes.splice(id, 1);
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

function clean_up_last() {
    console.log("Cleaning up last");
   
    while (notes[notes.length-1] == null) {
        console.log("Cleaning..");
        notes.pop();
        if (is_empty()){
            break;
        }
    }
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


function note_delete(id){
    console.log("Deleting " + c_note_id);
    // notes[c_note_id].delete();
    delet(id); 
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


// function add_fake_notes() {
//     var ex_note = new Note('0 note');
//     ex_note.text="Korem";
//     notes.push(ex_note); 
//     var ex_note = new Note('1 note');
//     // ex_note.image = true;
//     ex_note.tags = ["ho", "ma"];
//     notes.push(ex_note); 
//     var ex_note = new Note('2 note');
//     ex_note.tags = ['baby', 'person'];
//     notes.push(ex_note); 
//     var ex_note = new Note('3 note');
//     notes.push(ex_note); 
//     var ex_note = new Note('4 note');
//     ex_note.tags = ['ba'];
//     // ex_note.image = true;
//     notes.push(ex_note); 
//     var ex_note = new Note('5 note');
//     ex_note.image = true;
//     ex_note.snoozed = true;
//     ex_note.snoozed_date= "2019-03-28";
//     ex_note.snoozed_time= "14:00";
//     ex_note.text = "asdadas asdasd asd asd  ";
//     notes.push(ex_note); 
// }

function pull_notes() {
    console.log("Pulling notes request");
    $.ajax({
        url: "/server.php",
        async: true,
        type: "POST",
        header: {'Access-Control-Allow-Origin': '*'},
        data: "cmd=get_notes",
        success: function (result) {
            console.log("Pulling notes completed!");
            console.log(result);
            notes = result;
            unsnooze_notes();
        },
        error: function (xhr, ajaxOptions, thrownError) {
            console.log("Pullung notes ERROR!");
            console.log(xhr);
            console.log(thrownError);
        },
        contentType: 'application/x-www-form-urlencoded',
        dataType: 'json',
        });    

}

function push_notes() {
    console.log("Pushing notes request")
    // return;
    //correcting ids;
    //for (let i = 0; i < notes.length; i++) {
        //if (notes[i] == null){
            //continue;
        //}
        //notes[i].id = i;
    //}

    let data = JSON.stringify({
        cmd : "push_notes",
        notes : notes 
    });
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
    console.log("Processing file change");
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
                load_current_image(id);
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


function load_current_image(id) {
    //set image to current
    console.log("Loading current image request");
    console.log("Setting temp image");

    let empty1x1png = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVQI12NgYAAAAAMAASDVlMcAAAAASUVORK5CYII=";
    let sourcec = "data:image/png;base64," + empty1x1png;
    let url = sourcec; 
    $('#currentNoteImage').attr("src", url);
    $('#imageChangeIMG').attr("src", url);
    $('#unsnoozedNoteImage1').attr("src", url);

    let s_data = JSON.stringify( 
        {update_current : id}
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
                reload_current(id);
            } else {
                console.log(result);
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

function reload_current(id){
    if (id == null) {
        console.log("Cannot load image to null note");
        return;
    }
    if (notes[id].image){
        let url = "images/current.jpeg?rnd="+Math.random();
        $('#currentNoteImage').attr("src", url);
        $('#imageChangeIMG').attr("src", url);
        $('#unsnoozedNoteImage1').attr("src", url);
    }
}

function unsnooze_notes() {
    console.log("Unsnoozing notes");
    clean_up_last();
    let currentTime = myCurrentTime();
    let currentDate = myCurrentDate();
    for (let i = 0; i < notes.length; i++) {
        if (notes[i] == null){
            continue;
        }


        if (!notes[i].snoozed) {
            continue;
        }

        let do_add = false;

        // console.log(notes[i]);

        if (notes[i].snoozed == false) {
            notes[i].snoozed_date = "";
            notes[i].snoozed_time = "";
        }

       if (notes[i].snoozed_date < currentDate) {
        //console.log("edno");
           do_add = true;
       } else if (notes[i].snoozed_date == currentDate) {
            if (notes[i].snoozed_time <= currentTime) {
                do_add = true;
                //console.log("dve");
            } else {
                //console.log("dve2");
            }
       }

        if (do_add) {
                console.log("Add to to be unsnoozed " + notes[i].title);
                unsnooze.push( { note : notes[i], id: i } );

            }
    }

    print_notes();

}

function  myCurrentTime() {
    // return "";
    // return "15:30";
    let local = new Date();
    local.setMinutes(local.getMinutes() - local.getTimezoneOffset());
    return local.toJSON().slice(11,16);


    // let today = new Date();
    // let minutes;
    // let hours;
    // if (today.getHours() < 10) {
    //     hours = "0" + today.getHours();
    // } else {
    //     hours = today.getHours();
    // }
    // if (today.getMinutes() < 10) {
    //     minutes = "0" + today.getMinutes();
    // } else {
    //     minutes = today.getMinutes();
    // }
    // return  hours + ":" + minutes;
}

function myCurrentDate() {
    // return "";
    // return "2019-04-07";
    let local = new Date();
    local.setMinutes(local.getMinutes() - local.getTimezoneOffset());
    return local.toJSON().slice(0,10);
}

c_note_id = 1;
pull_notes();
