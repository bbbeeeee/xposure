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
    // $scope.requests = [
    // 	{
    // 		name: 'kevin tu',
    // 		email: 'brandonxtruong@gmail.com'
    // 	}
    // ]
    $http.get('http://mako.local:4567/active_sessions', {
    	params: { photographer_id: 1 }
    }).
	  success(function(data, status, headers, config) {
        console.log(data);
	  	$scope.requests = data;
        console.log($scope.requests);
	  	// alert(data);
	  }).
	  error(function(data, status, headers, config) {

	  });

    $scope.amount = 100
    $scope.sendPaymentRequest = function(){
    	$http.get('http://mako.local:4567/request_payment',
			{
			    params: { active_session_id: 1, amount: $scope.amount}
			}).
		  success(function(data, status, headers, config) {
            console.log(data)
		  }).
		  error(function(data, status, headers, config) {
            console.log(data);
		  });
    }


  });
