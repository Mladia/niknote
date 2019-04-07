
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
    console.log("Notes after pull");
    console.log(result);
            notes = result;
    console.log(notes);
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

    // print_notes();
}