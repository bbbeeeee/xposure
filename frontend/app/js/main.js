// var container = document.querySelector('#mediagrid');
// var msnry = new Masonry( container, {
//   // options
//   columnWidth: 200,
//   itemSelector: '.gridblock'
// });

// console.log("lol");

// console.log("haha");
// var x = document.getElementById("demo");
// function getLocation() {
//     if (navigator.geolocation) {
//         navigator.geolocation.getCurrentPosition(showPosition);
//     } else {
//         alert("Geolocation is not supported by this browser.");
//     }
// }

// function showPosition(position){
// 	console.log("hello");
// 	console.log(position);
// 	alert(position);
// }

// getLocation();

// var x = document.getElementById("demo");

// function getLocation() {
//     if (navigator.geolocation) {
//         navigator.geolocation.getCurrentPosition(showPosition);
//     } else { 
//         x.innerHTML = "Geolocation is not supported by this browser.";
//     }
// }

// function showPosition(position) {
//     x.innerHTML = "Latitude: " + position.coords.latitude + 
//     "<br>Longitude: " + position.coords.longitude;	
// }

$('.toggle-topbar a').on("click", function (e) {
        e.preventDefault();
    });