'use strict';

describe('Controller: RequestsCtrl', function () {

  // load the controller's module
  beforeEach(module('exposeApp'));

  var RequestsCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    RequestsCtrl = $controller('RequestsCtrl', {
      $scope: scope
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(scope.awesomeThings.length).toBe(3);
  });
});
