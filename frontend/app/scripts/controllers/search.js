angular.module('exposureApp')

.controller('SearchCtrl', function ($scope, $http, $location) {
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
			name: "Brandon Truong",
			information: "$20/hr for event, $200 for photoshoot",
			id: 3,
			imgurl: "img/brandon.jpg"
		}
	];

	$scope.photographers = $scope.fakepts;
	$http.get('http://graph.facebook.com/markcuban').
  success(function(data, status, headers, config) {
  	// $scope.photographers = $scope.fakept;
  	//actually assign data to $scope.photographers
  }).
  error(function(data, status, headers, config) {

  });
  // click a photographer, it's all good
  // $scope.clickPhotographer(id) = function(){

  // }

  $scope.alertt = function(){
  	alert('lol');
  }
  
  $scope.goToPhotographer = function(id){
  	console.log("hello");
  	$location.path('/photographer/' + id);
  }
});