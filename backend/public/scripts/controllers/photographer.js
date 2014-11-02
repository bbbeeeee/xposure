'use strict';

/**
 * @ngdoc function
 * @name exposeApp.controller:PhotographerCtrl
 * @description
 * # PhotographerCtrl
 * Controller of the exposeApp
 */
angular.module('exposureApp')
  .controller('PhotographerCtrl', function ($scope, $routeParams, $http) {
  	$scope.fakepts = [
      {
        name: "Kevin Tu",
        information: "$20/hr for event, $200 for photoshoot",
        id: 1,
        imgurl: "img/kevin.jpg"
      },
      {
        name: "Max Wang",
        information: "$20/hr for event, $200 for photoshoot",
        id: 2,
        imgurl: "img/max.jpg"
      },
      {
        name: "Eric Li",
        information: "$20/hr for event, $200 for photoshoot",
        id: 3,
        imgurl: "img/brandon.jpg"
      }
    ];
    
    $scope.photographer = $scope.fakepts[$routeParams.id];

  	console.log($routeParams.id);
  	$http.get('http://localhost:4567/list_active_photographers').
    success(function(data, status, headers, config) {
      $scope.photographer = data[$routeParams.id -1];
      console.log(data[$routeParams.id -1]);
      // $scope.photographers = $scope.fakept;
      //actually assign data to $scope.photographers
    }).
    error(function(data, status, headers, config) {

  });
  	function requestPhotographer_(position){
  		// send http request for hiring
      console.log(position);
      $http.get('http://mako.local:4567/request_photographer', {
        params: {
          session_id: $routeParams.id, email: $scope.email, location: position.coords.latitude + "," + position.coords.longitude
        }
      })
      .success(function(data, status, headers, config) {
        // 
        
      }).
      error(function(data, status, headers, config) {

      });
  	}

    function getLocation() {
      if (navigator.geolocation) {
          navigator.geolocation.getCurrentPosition(requestPhotographer_);
      } else { 
          x.innerHTML = "Geolocation is not supported by this browser.";
      }
    }

    $scope.requestPhotographer = function(){
      getLocation();
    }
  });
