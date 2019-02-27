<?php
    $notes = file_get_contents('notes');

    $contentType = explode(';', $_SERVER['CONTENT_TYPE']); // Check all available Content-Type
    $rawBody = file_get_contents("php://input"); // Read body
    $data = array(); // Initialize default data array

    if(in_array('application/json', $contentType)) { // Check if Content-Type is JSON
        $data = json_decode($rawBody); // Then decode it
    } else {
        parse_str($data, $data); // If not JSON, just do same as PHP default method
    }

    // echo json_encode(array( // Return data
    //     'data' => $data
    // ));

    // print_r($data);
    var_dump($data);
    echo "HOPRAA";
    if($data->cmd == "push_notes"){
        echo "da";
        $data->notes = $notes;
        file_put_contents('notes_put', $data->notes);
    }

    // echo $data;

    if ($_POST["cmd"] == "get_notes") {
        header('Content-Type: application/json; charset=UTF-8');
        echo $notes;
    }
?>
