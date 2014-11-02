'use strict';

describe('Controller: PhotographerCtrl', function () {

  // load the controller's module
  beforeEach(module('exposeApp'));

  var PhotographerCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    PhotographerCtrl = $controller('PhotographerCtrl', {
      $scope: scope
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(scope.awesomeThings.length).toBe(3);
  });
});
