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
        imgurl: "http://google.com/google.jpg",
        information: "$20/hr for event, $200 for photoshoot",
        id: 1,
        imgurl: "img/kevin.jpg"
      },
      {
        name: "Max Wang",
        imgurl: "http://google.com/google.jpg",
        information: "$20/hr for event, $200 for photoshoot",
        id: 2,
        imgurl: "img/max.jpg"
      },
      {
        name: "Eric Li",
        imgurl: "http://google.com/google.jpg",
        information: "$20/hr for event, $200 for photoshoot",
        id: 3,
        imgurl: "img/brandon.jpg"
      }
    ];
    
    $scope.photographer = {

  	}
  	console.log($routeParams.id);
  	$http.get('http://graph.facebook.com/markcuban').
	  success(function(data, status, headers, config) {
	  	// get data and assign to photographer
	  	//alert(data);
	  }).
	  error(function(data, status, headers, config) {

	  });
  	$scope.hire = function(id){
  		// send http request for hiring
      $http.post('http://graph.facebook.com/markcuban', {id: id, amt: 10})
      success(function(data, status, headers, config) {
        // 
        alert(data);
      }).
      error(function(data, status, headers, config) {

      });
  	}
  });
