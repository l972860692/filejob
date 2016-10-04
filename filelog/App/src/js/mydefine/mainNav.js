angular.module('user.mainNav', [])
.controller('mainNav', ['$scope', '$http', function ($scope, $http) {

    $scope.menus = [];

    $http.get('/api/jobname').
  success(function (data, status, headers, config) {
     
      
      var menusLog = new MenuObject('1', 'Log')
      var menusfileJobLog = new MenuObject('11', 'fileJobLog')
      menusLog.childMenu.push(menusfileJobLog);
      data.forEach(function () {
          var tempChildMenu = new MenuObject('11'+arguments[1],arguments[0] )
          menusfileJobLog.childMenu.push(tempChildMenu);
      })
      //for test
      /* 
      var menusfileJobLog = new MenuObject(11, 'fileJobLog')
      var menusfileJobLog_tvLog = new MenuObject(111, 'tvLog')
      var menusfileJobLog_vasLog = new MenuObject(112, 'vasLog')
      menusfileJobLog.childMenu.push(menusfileJobLog_tvLog);
      menusfileJobLog.childMenu.push(menusfileJobLog_vasLog);
      */
    
      $scope.menus.push(menusLog);
  }).
  error(function (data, status, headers, config) {
      // called asynchronously if an error occurs
      // or server returns response with an error status.
  });
   // $http.get("/api/Menu").scuccess(function (data, status, headers, config) {
       
        //only test
       
  //  })


}])

function MenuObject(id,name,icon,sort) {
    var obj = new Object();
    obj.id = id;
    obj.name = name;
   // obj.sort = sort;   
  //  obj.icon = icon;
    obj.childMenu = [];
    return obj;

}