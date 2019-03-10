<?php
    // ini_set('display_errors', 1);
    // ini_set('display_startup_errors', 1);
    // error_reporting(E_ALL);


    $contentType = explode(';', $_SERVER['CONTENT_TYPE']); // Check all available Content-Type
    $rawBody = file_get_contents("php://input"); // Read body
    $data = array(); // Initialize default data array
    if(in_array('application/json', $contentType)) { // Check if Content-Type is JSON
        $data = json_decode($rawBody); // Then decode it
    } else {
        parse_str($data, $data); // If not JSON, just do same as PHP default method
    }


   $images_folder = "notes_images";

    if ($_POST['push'] == "yes") {
        assert ($_POST["id"] != "");
        assert ($_POST["imageData"] != "");
        //request to upload image
        $note_id = $_POST["id"];
        $data = $_POST["imageData"];
        push_image($note_id, $data);
    } elseif($data->cmd == "push_notes"){
        push_notes($data->notes);
    } elseif ($_POST["cmd"] == "get_notes") {
        get_notes();
    } elseif (is_numeric($data->update_current)) {
        update_current($data->update_current);
    }



    function push_image($note_id, $data){
        $images_folder = $GLOBALS["images_folder"];

        if (preg_match('/^data:image\/(\w+);base64,/', $data, $type)) {
            $data = substr($data, strpos($data, ',') + 1);
            $type = strtolower($type[1]); // jpg, png, gif
        
            // if (!in_array($type, [ 'jpg', 'jpeg', 'gif', 'png' ])) {
            //     throw new \Exception('invalid image type');
            // }
        
            if (!in_array($type, [ 'jpg', 'jpeg'])) {
                // throw new \Exception('invalid image type');
                die('invalid image type ' . $type);
            }
            $data = base64_decode($data);
        
            if ($data === false) {
                // throw new \Exception('base64_decode failed');
                die('base64_decode failed');
            }
        } else {
            // throw new \Exception('did not match data URI with image data');
            die('did not match data URI with image data');
        }

        //TODO:
        // convert to jpg

        if (!is_dir($images_folder)) {
            // dir doesn't exist, make it
            mkdir($images_folder);
        }
        $rc = file_put_contents("${images_folder}/img_${note_id}.${type}", $data);
        // file_put_contents("${images_folder}/img_${note_id}.jpeg", $img);
        if ($rc) {
            echo '{"success" : "true"}';
        } else {
            echo '{"success" : "false"}';
        }
    }

    function update_current($note_id){
        $images_folder = $GLOBALS["images_folder"];
        // $note_id = $data->update_current;
        $src = "${images_folder}/img_${note_id}.jpeg";
        $dest = "images/current.jpeg";

        if (!is_dir("images")) {
            // dir doesn't exist, make it
            mkdir("images/");
        }

        $rc = copy($src, $dest);
        if ($rc) {
            echo '{"success" : "true"}';
        } else {
            echo '{"success" : "false"}';
        }
    }

    function push_notes($data_notes){
        // $data->notes = $notes;
        // echo $notes;
        $rc = file_put_contents('rsc/notes', json_encode($data_notes), LOCK_EX);
        header('Content-Type: application/json');
        if ($rc) {
            echo '{"success" : "true"}';
        } else {
            echo '{"success" : "false"}';
        }
        
    }

    function get_notes(){
        $notes = file_get_contents('rsc/notes', LOCK_EX);
        header('Access-Control-Allow-Origin: *; Content-Type: application/json; charset=UTF-8');
        // $notes = fread($filelink, filesize($filename));
        // fwrite($filelink, json_encode($data->notes));
        echo $notes;
    }

?>
