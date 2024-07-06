function openNPCDriverMenu() {
    // Fetch NPC drivers' data and populate the menu
    $.post('https://your_resource_name/fetchNPCDrivers', JSON.stringify({}), function(drivers) {
        let npcDriversList = $('#npc-drivers-page-list');
        npcDriversList.empty();
        
        drivers.forEach(driver => {
            npcDriversList.append(`
                <div class="col-12 mt-2 mb-2">
                    <div class="card card-centering">
                        <div class="card-content">
                            <div class="card-body">
                                <div class="media d-flex">
                                    <div class="media-body text-left">
                                        <h3 class="text-primary">${driver.name}</h3>
                                        <span>Earnings: $${driver.earnings}</span>
                                    </div>
                                    <div class="align-self-center">
                                        <button class="btn btn-danger" onclick="fireNPCDriver('${driver.id}')">Fire</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            `);
        });

        // Show the NPC drivers page
        $('.main').show();
    });
}

function addNPCDriver() {
    $.post('https://your_resource_name/addNPCDriver', JSON.stringify({}), function(response) {
        if (response.success) {
            openNPCDriverMenu(); // Refresh the NPC drivers menu
        } else {
            alert('Failed to add NPC driver');
        }
    });
}

function fireNPCDriver(id) {
    $.post('https://your_resource_name/fireNPCDriver', JSON.stringify({ id: id }), function(response) {
        if (response.success) {
            openNPCDriverMenu(); // Refresh the NPC drivers menu
        } else {
            alert('Failed to fire NPC driver');
        }
    });
}

// Event listener for opening the NPC driver menu
$(document).on('keydown', function(event) {
    if (event.key === 'F6') { // Example key, change as needed
        openNPCDriverMenu();
    }
});
