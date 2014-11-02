'use strict';

/**
 * @ngdoc function
 * @name exposeApp.controller:RequestsCtrl
 * @description
 * # RequestsCtrl
 * Controller of the exposeApp
 */
angular.module('exposureApp')
  .controller('RequestsCtrl', function ($scope, $http) {
    $scope.requests = [
    	{
    		name: 'kevin tu',
    		email: 'brandonxtruong@gmail.com'
    	}
    ]
    $http.get('http://graph.facebook.com/markcuban').
	  success(function(data, status, headers, config) {
	  	// get all requests
	  	// alert(data);
	  }).
	  error(function(data, status, headers, config) {

	  });
    
    $scope.sendPaymentRequest = function(amount, id){

    }


  });
