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
    $http.get('http://localhost:4567/active_sessions', {
    	params: { photographer_id: 1 }
    }).
	  success(function(data, status, headers, config) {
	  	$scope.requests = data;
	  	// alert(data);
	  }).
	  error(function(data, status, headers, config) {

	  });
    $scope.amounts = 'lol'
    $scope.sendPaymentRequest = function(id){
    	alert($scope.amounts);
    	$http.get('localhost:4567/request_payment',
			{
			    params: { active_session_id: id, amount: $scope.amount}
			}).
		  success(function(data, status, headers, config) {
		  	$scope.requests = data;
		  	// alert(data);
		  }).
		  error(function(data, status, headers, config) {

		  });
    }


  });
