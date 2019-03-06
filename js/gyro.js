
window.addEventListener("deviceorientation", handleOrientation, true);
var output = document.querySelector('.output');
var in_alpha = 0;
var in_beta = 0;
var in_gamma = 0;
var alpha = 0;
var beta = 0;
var gamma = 0;

var first_flip_gb = false;
var first_flip_gf = false;
var first_flip_d = false;
var first = true;
var flipped_degree = 80;
var margin_error = 15;

function met(x, limit){
    if ( Math.abs( x - limit ) < margin_error ){
        return true;
    }else{
        false;
    }
}

function check_snooze() {
    if ( met(gamma, 85) && met(beta, 130) ) {
        first_flip_gb = true
        output.innerHTML += "1first!\n";
    }
    if (first_flip_gb && met(gamma, in_gamma) && met(beta, in_beta ) ){
        first_flip_gb = false;
        output.innerHTML += "1second!\n";
        show_snooze_modal();
    }
}

function check_go_for() {
    if ( met(gamma, -85) && met(beta, 130) ) {
        first_flip_gf = true
        output.innerHTML += "2first!\n";
    }
    if (first_flip_gf && met(gamma, in_gamma) && met(beta, in_beta ) ){
        first_flip_gf = false;
        output.innerHTML += "2second!\n";
        go_for_note();
    }
}

function check_done(){
    if ( met(beta - in_beta, 80) && met(gamma, in_gamma) ){
        first_flip_d = true;
        output.innerHTML += "3first!\n";
    }
    if (first_flip_d && met(beta, in_beta) && met(gamma, in_gamma)) {
        first_flip_d = false;
        output.innerHTML += "3second!\n";
        c_note_done();
    }
}
function handle_gestures(){
    check_snooze();
    check_go_for();
    check_done();

}



function handleOrientation(event) {
    // var absolute = event.absolute;
    alpha    = event.alpha;
    beta     = event.beta;
    gamma    = event.gamma;
  

    output.innerHTML = "";
    output.innerHTML = "alpha: " + alpha + "\n";
    output.innerHTML += "beta: " + beta + "\n";
    output.innerHTML += "gamma: " + gamma + "\n";
    output.innerHTML += "in_alpha: " + in_alpha + "\n";
    output.innerHTML += "in_beta: " + in_beta + "\n";
    output.innerHTML += "in_gamma: " + in_gamma+ "\n";

    if (first) {
        in_alpha = alpha;
        in_beta = beta;
        in_gamma = gamma;
        first = false;
    }

    handle_gestures();
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
		}
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
        sendFile(c_note_id, image_to_upload);
        //show imageBlock
        show_photo_new_dialog();
	};

	image.onerror = function () {
		alert('There was an error processing your file!');
	};
}



function sendFile(id, fileData) {
    console.log("Sending file");
	var formData = new FormData();

    formData.append('id', id);
    formData.append('imageData', fileData);
    
    // return;
	$.ajax({
		type: 'POST',
		url: '/server.php',
		data: formData, 
		contentType: false,
        processData: false,
        dataType: "json",
		success: function (data) {
            console.log(data);
			if (data.success) {
				alert('Your file was successfully uploaded!');
			} else {
				alert('There was an error uploading your file1!');
			}
		},
		error: function (data) {
            console.log(data);
			alert('There was an error uploading your file2!');
		}
    });
    
    new_image = false;
    image_to_upload = "";
}