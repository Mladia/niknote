
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

