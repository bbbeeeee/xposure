'use strict';

/**
 * @ngdoc overview
 * @name exposureApp
 * @description
 * # exposureApp
 *
 * Main module of the application.
 */
angular
  .module('exposureApp', [
    'ngAnimate',
    'ngCookies',
    'ngResource',
    'ngRoute',
    'ngSanitize',
    'ngTouch'
  ])
  .config(function ($routeProvider) {
    $routeProvider
      // .when('/', {
      //   templateUrl: 'views/main.html',
      //   controller: 'MainCtrl'
      // })
      .when('/about', {
        templateUrl: 'views/about.html',
        controller: 'AboutCtrl'
      })
      .when('/search', {
        templateUrl: 'views/search.html',
        controller: 'SearchCtrl'
      })
      .when('/login', {
        templateUrl: 'views/login.html',
        controller: 'LoginCtrl'
      })
      .when('/photographer', {
        templateUrl: 'views/fakept.html',
        controller: 'PhotographerCtrl'
      })
      .when('/photographer/:id', {
        templateUrl: 'views/photographer.html',
        controller: 'PhotographerCtrl'
      })
      .when('/account', {
        templateUrl: 'views/account.html',
        controller: 'AccountCtrl'
      })
      .when('/requests', {
        templateUrl: 'views/requests.html',
        controller: 'RequestsCtrl'
      })
      .when('/payment', {
        templateUrl: 'views/payment.html',
        controller: 'PaymentCtrl'
      });
  });
