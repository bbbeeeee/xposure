'use strict';

/**
 * @ngdoc function
 * @name exposureApp.controller:AboutCtrl
 * @description
 * # AboutCtrl
 * Controller of the exposureApp
 */
angular.module('exposureApp')
  .controller('AboutCtrl', function ($scope) {
    $scope.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];
  });
