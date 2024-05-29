const url = "https://federatednode.uksouth.analytixagility.aridhiadev.net";
Shiny.addCustomMessageHandler("submitTask", function (token) {
    var image = $('select#image').val();
    $("button#task").attr("disabled", true);
    var settings = {
        "url": url + "/tasks/",
        "method": "POST",
        "timeout": 0,
        "headers": {
            "Content-Type": "application/json",
            "Authorization": "Bearer " + token
        },
        "data": JSON.stringify({
            "name": "Test Task",
            "executors": [
                {
                    "image": image,
                    "command": [
                        "R",
                        "-e",
                        "df <- as.data.frame(installed.packages())[,c('Package', 'Version')];write.csv(df, file='/mnt/data/packages.csv', row.names=FALSE);Sys.sleep(10)"
                    ],
                    "env": {
                        "VARIABLE_UNIQUE": 123,
                        "USERNAME": "test"
                    }
                }
            ],
            "tags": {
                "dataset_id": 1,
                "test_tag": "some content"
            },
            "inputs": {},
            "outputs": {},
            "resources": {
                "limits": {
                    "cpu": "100m",
                    "memory": "100Mi"
                },
                "requests": {
                    "cpu": "0.1",
                    "memory": "50Mi"
                }
            },
            "volumes": {},
            "description": "First task ever!"
        })
    };
    $.ajax(settings).done(function (response) {
        Shiny.setInputValue("task_id", response["task_id"]);
        $("div#task_id").text("Created task with id: " + response["task_id"]);
        $("div#task_status").text("Task status: Initializing");
        $("button#status").removeAttr("disabled");
        $("div#fn_error").text('');
    })
        .fail(function (xmlhttp, textStatus) {
            $("button#task").removeAttr("disabled");
            $("div#fn_error").text(xmlhttp.responseJSON["error"]);
        });
}
);

Shiny.addCustomMessageHandler("checkStatus", function (args) {
    args = args.split(',');
    token = args[0];
    id = args[1];

    $("button#status").attr("disabled", true);
    var settings = {
        "url": url + "/tasks/" + id,
        "method": "GET",
        "timeout": 0,
        "headers": {
            "Authorization": "Bearer " + token,
        }
    };
    $.ajax(settings).done(function (response) {
        task_status = Object.keys(response["status"])[0]
        $("div#task_status").text("Task status: " + task_status);
        Shiny.setInputValue("task_status", task_status);
        if (task_status == "terminated")
            $("button#results").removeAttr("disabled");
        else
            $("button#status").removeAttr("disabled");
        $("div#fn_error").text('');
        })
        .fail(function (xmlhttp, textStatus) {
            $("button#status").removeAttr("disabled");
            $("div#fn_error").text(xmlhttp.responseJSON["error"]);
        });
});
Shiny.addCustomMessageHandler("getResults", function (args) {
    args = args.split(',');
    token = args[0];
    id = args[1];

    $("button#results").attr("disabled", true);
    var settings = {
        "url": `https://federatednode.uksouth.analytixagility.aridhiadev.net/tasks/${id}/results`,
        "method": "GET",
        "timeout": 0,
        "headers": {
            "Authorization": `Bearer ${token}`
        }
    };

    $.ajax(settings).done(function (response) {
        $("button#task").removeAttr("disabled");
        $("div#task_status").text("Task status: completed");
        $("div#fn_error").text('');
        $("div#results").text(`Results can be found in the 'Files' tab under results/${id}/ folder`);
    })
    .fail(function (xmlhttp, textStatus) {
        $("button#results").removeAttr("disabled");
        $("div#fn_error").text(xmlhttp.responseJSON["error"]);
    });
});
