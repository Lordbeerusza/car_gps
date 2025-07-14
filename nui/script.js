window.addEventListener("message", function (event) {
    const tracker = document.getElementById("tracker");
    const noGPS = document.getElementById("noGPS");
    const select = document.getElementById("plateSelect");

    switch (event.data.action) {
        case "open":
            select.innerHTML = "";
            event.data.plates.forEach(plate => {
                const option = document.createElement("option");
                option.value = plate;
                option.textContent = plate;
                select.appendChild(option);
            });
            noGPS.style.display = "none";
            tracker.style.display = "block";
            break;

        case "close":
            tracker.style.display = "none";
            noGPS.style.display = "none";
            break;

        case "empty":
            tracker.style.display = "none";
            noGPS.style.display = "block";
            break;
    }
});

function trackVehicle() {
    const plate = document.getElementById("plateSelect").value;
    if (plate && plate.length > 0) {
        fetch(`https://${GetParentResourceName()}/trackVehicle`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ plate })
        });
    }
}

function closeUI() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
    });
}

document.addEventListener("keydown", function (event) {
    if (["Escape", "Backspace"].includes(event.key)) {
        closeUI();
    }
});
