var currentMenu = null
var menuOptions = null

function actionSend(action) {
    // get form data

    let data = {};
    data["action"] = action.action
    action.params.forEach(param => {
        const value = document.getElementById(param.name).value
        data[param.name] = value
    })

    // document.getElementsByTagName("form")[0].appendChild(document.createTextNode(JSON.stringify(data)));

    mta.triggerEvent("action", JSON.stringify(data))
}

function changeMenu(action) {
    const panel = document.getElementsByClassName("options-panel")[0];
    while (panel.lastElementChild) {
        panel.removeChild(panel.lastElementChild)
    }
    
    const title = document.createElement("h1");
    title.textContent = action.name
    panel.appendChild(title)

    const form = document.createElement("form")
    action.params.forEach(param => {
        const label = document.createElement("label")
        label.textContent = param.label
        label.setAttribute("for", param.name)

        let input;
        switch (param.type) {
            case "long-text":
                input = document.createElement("textarea")
                input.type = "text"
                input.value = ""
                input.setAttribute("rows", "5")
                break;
            case "text":
                input = document.createElement("input")
                input.type = "text"
                input.value = ""
                break;
            case "number":
                input = document.createElement("input");
                input.type = "number";
                input.value = 0;
                break;
            case "number-range":
                input = document.createElement("input");
                input.type = "number";
                input.min = param.range[0];
                input.max = param.range[1];
                input.value = param.range[0];
                break;
            case "player":
                input = document.createElement("input");
                input.type = "text";
                input.value = "localPlayer";
                break;
            case "dropdown":
                input = document.createElement("select");
                param.options.forEach(option => {
                    const opt = document.createElement("option");
                    opt.value = option;
                    opt.textContent = option;
                    input.appendChild(opt);
                });
                input.value = param.options[0];
                break;
            default:
                return;
        }
        input.id = param.name

        const div = document.createElement("div");
        div.className = "form-field"
        div.appendChild(label);
        div.appendChild(input);
        
        form.appendChild(div);
    });

    const submitButton = document.createElement("button");
    submitButton.type = "submit";
    submitButton.textContent = "Submit";
    submitButton.style.marginTop = "10px";
    form.appendChild(submitButton);

    form.onsubmit = function(e) {
        e.preventDefault();
        actionSend(action)
    }

    panel.appendChild(form)
}

fetch("./admin_actions.json")
    .then(r => r.json())
    .then(data => {
        menuOptions = data
        data.forEach(action => {
            var button = document.createElement("button");
            button.className = "sidebar-option";
            button.textContent = action.name;
            button.addEventListener("click", function() {changeMenu(action)});
            document.getElementsByClassName("sidebar")[0].appendChild(button);
        });
    })
    .catch(c => console.log(c));