'use strict';

/**
 * @ngdoc function
 * @name exposureApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the exposureApp
 */
angular.module('exposureApp')
  .controller('MainCtrl', function ($scope) {
    $scope.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];
  });
