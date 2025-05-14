const today = new Date();
        const formattedDate = today.toISOString().split('T')[0];
        document.getElementById('taskDate').min = formattedDate;
        document.getElementById('td1').min = formattedDate;
        window.onload = function () {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('taskDate')) {
            document.getElementById("taskList").style.display = "block";
        }
};
function navigateTo(sectionId) {
    document.querySelectorAll('.section').forEach(section => {
        section.style.display = 'none';
    });
    document.getElementById(sectionId).style.display = 'block';
}

function logout() {
    window.location.href = "logout.jsp";
}

document.getElementById("taskDateForm").addEventListener("submit", function (event) {
    event.preventDefault();

    const selectedDate = document.getElementById("taskDate").value;
    const formAction = this.getAttribute("action");

    window.location.href = formAction + "?taskDate=" + selectedDate;
});