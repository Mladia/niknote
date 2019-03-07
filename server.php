<?php

    $images_folder = "notes_images";

    $contentType = explode(';', $_SERVER['CONTENT_TYPE']); // Check all available Content-Type
    $rawBody = file_get_contents("php://input"); // Read body
    $data = array(); // Initialize default data array
    if(in_array('application/json', $contentType)) { // Check if Content-Type is JSON
        $data = json_decode($rawBody); // Then decode it
    } else {
        parse_str($data, $data); // If not JSON, just do same as PHP default method
    }
    // echo var_dump($_FILES['image']);
    // $filename = "notes";
    // echo $filename;
    // $filelink= fopen($filename, 'w+');
    if ($_POST['push'] == "yes") {
        assert ($_POST["id"] != "");
        assert ($_POST["imageData"] != "");
        //request to upload image
        $note_id = $_POST["id"];
        $data = $_POST["imageData"];

        if (preg_match('/^data:image\/(\w+);base64,/', $data, $type)) {
            $data = substr($data, strpos($data, ',') + 1);
            $type = strtolower($type[1]); // jpg, png, gif
        
            if (!in_array($type, [ 'jpg', 'jpeg', 'gif', 'png' ])) {
                throw new \Exception('invalid image type');
            }
        
            $data = base64_decode($data);
        
            if ($data === false) {
                throw new \Exception('base64_decode failed');
            }
        } else {
            throw new \Exception('did not match data URI with image data');
        }

        //TODO:
        // convert to jpeg

        if (!is_dir($images_folder)) {
            // dir doesn't exist, make it
            mkdir($images_folder);
        }
        file_put_contents("${images_folder}/img_${note_id}.{$type}", $data);
        // file_put_contents("${images_folder}/current", $data);

        echo '{"success" : "true"}';
    }

    mkdir("images/");

    if (is_numeric($data->update_current)) {
        $note_id = $data->update_current;
        copy("${images_folder}/img_${note_id}.jpeg", "images/current.jpeg");
        echo '{"success" : "true"}';
    }

    if($data->cmd == "push_notes"){
        // $data->notes = $notes;
        // echo $notes;
        file_put_contents('rsc/notes', json_encode($data->notes), LOCK_EX);
        // fwrite($filelink, json_encode($data->notes));
        header('Content-Type: application/json; charset=UTF-8');
        echo json_encode($data->notes);
        // echo '{"status" : "WRITTEN"}';
        
    }

    if ($_POST["cmd"] == "get_notes") {
        header('Access-Control-Allow-Origin: *; Content-Type: application/json; charset=UTF-8');
        $notes = file_get_contents('rsc/notes', LOCK_EX);
        // $notes = fread($filelink, filesize($filename));
        echo $notes;
    }

    fclose($filelink);
?>
