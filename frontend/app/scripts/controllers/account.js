'use strict';

/**
 * @ngdoc function
 * @name exposeApp.controller:AccountCtrl
 * @description
 * # AccountCtrl
 * Controller of the exposeApp
 */
angular.module('exposureApp')
  .controller('AccountCtrl', function ($scope, $http) {
  	$scope.user = {
  		name: "Kevin Tu",
  		description: "Hello world"
  	}

    $http.get('http://graph.facebook.com/markcuban').
	  success(function(data, status, headers, config) {
	  	// assign data to scope and allow you to see this
	  	// alert(data);
	  }).
	  error(function(data, status, headers, config) {

	  });
  });
