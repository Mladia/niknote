<?php

    $images_folder = "notes_images/";

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
    if ($_POST["id"] != "") {
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

        if (!is_dir($images_folder)) {
            // dir doesn't exist, make it
            mkdir($images_folder);
          }
        file_put_contents("${images_folder}img_${note_id}.{$type}", $data);
        echo '{"status" : "WRITTEN"}';
    }


    if($data->cmd == "push_notes"){
        // $data->notes = $notes;
        // echo $notes;
        file_put_contents('notes', json_encode($data->notes), LOCK_EX);
        // fwrite($filelink, json_encode($data->notes));
        header('Content-Type: application/json; charset=UTF-8');
        echo json_encode($data->notes);
        // echo '{"status" : "WRITTEN"}';
        
    }

    // echo $data;

    if ($_POST["cmd"] == "get_notes") {
        header('Access-Control-Allow-Origin: *; Content-Type: application/json; charset=UTF-8');
        $notes = file_get_contents('notes', LOCK_EX);
        // $notes = fread($filelink, filesize($filename));
        echo $notes;
    }
    fclose($filelink);
?>
