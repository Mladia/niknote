<?php

    $contentType = explode(';', $_SERVER['CONTENT_TYPE']); // Check all available Content-Type
    $rawBody = file_get_contents("php://input"); // Read body
    $data = array(); // Initialize default data array
    if(in_array('application/json', $contentType)) { // Check if Content-Type is JSON
        $data = json_decode($rawBody); // Then decode it
    } else {
        parse_str($data, $data); // If not JSON, just do same as PHP default method
    }

    // $filename = "notes";
    // echo $filename;
    // $filelink= fopen($filename, 'w+');

    if($data->cmd == "push_notes"){
        // $data->notes = $notes;
        // echo $notes;
        file_put_contents('notes', json_encode($data->notes), LOCK_EX);
        // fwrite($filelink, json_encode($data->notes));
        echo '{"status" : "WRITTEN"}';
    }

    // echo $data;

    if ($_POST["cmd"] == "get_notes") {
        header('Content-Type: application/json; charset=UTF-8');
        $notes = file_get_contents('notes', LOCK_EX);
        // $notes = fread($filelink, filesize($filename));
        echo $notes;
    }
    fclose($filelink);
?>
