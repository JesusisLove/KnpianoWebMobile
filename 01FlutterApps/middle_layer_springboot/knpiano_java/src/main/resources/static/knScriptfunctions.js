// knScriptfunctions.js
// function getButtonStates(info) {
//     let states = {
//         change: '',
//         delete: '',
//         sign: '',
//         cancel: ''
//     };

//     if (info.lessonType == 0 && info.schedualDate && !info.lsnAdjustedDate && !info.scanQrDate) {
//         states.change = '';
//         states.delete = '';
//         states.sign = '';
//         states.cancel = 'disabled';
//     }
//     return states;
// }

// function initializeYearDropdown() {
//     const currentYear = new Date().getFullYear();
//     const startYear = 2020;
//     const dropdown = document.getElementById('lsnfeeyear');

//     // Clear existing options except the first empty one
//     dropdown.innerHTML = '<option value=""></option>';

//     // Populate the dropdown with years from currentYear to startYear
//     for (let year = currentYear; year >= startYear; year--) {
//         const option = document.createElement('option');
//         option.value = year;
//         option.textContent = year;
//         dropdown.appendChild(option);
//     }

//     // Set the default selected option to the current year
//     dropdown.value = currentYear;
// }

// function initializeMonthDropdown() {
//     const currentMonth = new Date().getMonth() + 1; // JavaScript months are 0-11
//     const monthDropdown = document.getElementById('monthSelect');
//     const months = [
//         '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'
//     ];

//     // Clear existing options
//     monthDropdown.innerHTML = '';

//     // Populate the dropdown with months
//     months.forEach((month, index) => {
//         const option = document.createElement('option');
//         option.value = index + 1; // Month value should be 1-12
//         option.textContent = month;
//         monthDropdown.appendChild(option);
//     });

//     // Set the default selected option to the current month
//     // const currentMonthPadded = String(currentMonth).padStart(2, '0'); // Ensure the current month has leading zero
//     // monthDropdown.value = currentMonthPadded;

//     monthDropdown.value = currentMonth;
// }