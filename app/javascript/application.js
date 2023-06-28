// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
// import "controllers"

// Reads ticket polygon and build the google maps
window.initMap = function(wktPolygon) {
  var mapElement = document.getElementById('map');
  var wktPolygon = mapElement.dataset.wktPolygon;

  var center = { lat: -50, lng: 150 };

  var map = new google.maps.Map(document.getElementById('map'), {
    zoom: 8,
    center: center
  });

  var coordinates = wktPolygon.replace("POLYGON((", "").replace("))", "").split(",");

  var latLngArray = [];

  // Iterate over coordinates and create new google.maps.LatLng for each coordinate
  for (var i = 0; i < coordinates.length; i++) {
    var latLng = coordinates[i].split(" ");
    latLngArray.push({ lat: parseFloat(latLng[1]), lng: parseFloat(latLng[0]) });
  }

  // Create the google maps object
  var map_polygon = new google.maps.Polygon({
    paths: latLngArray,
    strokeWeight: 0,
    fillColor: '#355c82',
    fillOpacity: 0.45
  });

  // Add the polygon to the map
  map_polygon.setMap(map);

  var bounds = new google.maps.LatLngBounds();
  map_polygon.getPath().forEach(function (latLng) {
    bounds.extend(latLng);
  });
  map.fitBounds(bounds);
}

// Access google maps API with the correct API KEY
function loadGoogleMapsAPI() {
  const script = document.createElement('script');
  script.src = `https://maps.googleapis.com/maps/api/js?key=${window.GOOGLE_API_KEY}&callback=initMap`;
  document.head.appendChild(script);
}

document.addEventListener("DOMContentLoaded", function() {
  loadGoogleMapsAPI();
});

// Make the tr tag a link
document.addEventListener('DOMContentLoaded', function() {
  const rows = document.querySelectorAll('tr[data-url]');
  rows.forEach(row => {
    row.addEventListener('click', () => {
      window.location.href = row.dataset.url;
    });
  });
});

// Deals with the background color when hovering a table roww
document.querySelectorAll('tr').forEach(function(td) {
  td.addEventListener('mouseenter', function() {
    this.classList.add('row-hover');
  });

  td.addEventListener('mouseleave', function() {
    this.classList.remove('row-hover');
  });

  document.querySelectorAll('.pagination a').forEach(link => {
    link.addEventListener('mouseover', function() {
      this.style.textDecoration = 'underline';
    });
 
    link.addEventListener('mouseout', function() {
      this.style.textDecoration = 'none';
    });
  });
});