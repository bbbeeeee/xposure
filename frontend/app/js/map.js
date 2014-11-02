var x = document.getElementById("demo");

function getLocation() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(initialize);
    } else { 
        x.innerHTML = "Geolocation is not supported by this browser.";
    }
}

function showPosition(position) {
    x.innerHTML = "Latitude: " + position.coords.latitude + 
    "<br>Longitude: " + position.coords.longitude;  
}


var map;

function initialize(position) {
  var mapOptions = {
    zoom: 12,
    center: new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
  };
    
  map = new google.maps.Map(document.getElementById('map-canvas'),
      mapOptions);

  var populationOptions = {
      strokeColor: '#FF0000',
      strokeOpacity: 0.8,
      strokeWeight: 2,
      fillColor: '#FF0000',
      fillOpacity: 0.35,
      map: map,
      center: new google.maps.LatLng(position.coords.latitude, position.coords.longitude),
      radius: 3000
    };

  var marker = new google.maps.Marker({
      position: new google.maps.LatLng(position.coords.latitude, position.coords.longitude),
      map: map,
      title: 'Hello World!'
  });
  
  cityCircle = new google.maps.Circle(populationOptions);
}

google.maps.event.addDomListener(window, 'load', getLocation);