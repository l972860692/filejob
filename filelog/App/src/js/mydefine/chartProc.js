angular.module('user.chartProc', ['app','chart.js'])
.controller('chartProcCtr', ['$scope', '$http', '$stateParams', '$modal', '$state', 'showModal', function ($scope, $http, $stateParams, $modal, $state, showModal) {
    //'showModal'
    $scope.urlParm = $stateParams.fold;
    $scope.datatotal = [];

    $scope.d0_3 = [[0, 10], [1, 15], [2, 27], [3, 41.5], [45, 3], [5, 3.5], [6, 6], [7, 3], [8, 4], [9, 3]];

    $scope.d0_2 = [[0, 24], [1, 45], [2, 7], [3, 4.5], [4, 3], [5, 3.5], [6, 6], [7, 3], [8, 4], [9, 3]];
    $scope.labels = []

    $scope.onClick = function (points, evt) {
        console.log(points, evt);
    };

    var nowTime = new Date();
    var theBeginDate = Date(nowTime.getYear, nowTime.getMonth - 1, 1);
    var theEndDate = nowTime;
    var jobDataModel = { JobName: $scope.urlParm, TheBeginDate: '2016-03-01', TheEndDate: '2016-03-08' };
    $http.post('/api/JobTableMactchData', jobDataModel).success(
      function (data) {
          $scope.datatotaljob = [];
          $scope.datatotaltable = [];
          $scope.data1 = []
          $scope.data2 = []
          data.forEach(function () {
              if (arguments[0].logdata == null) {
                  arguments[0].logdata = 0;
              }
              if (arguments[0].tabledata == null) {
                  arguments[0].tabledata = 0;
              }
              //  $scope.datatotaljob.push([arguments[0].theday, arguments[0].logdata]);
              // $scope.datatotaltable.push([arguments[0].theday, arguments[0].tabledata]);
              $scope.data1.push(arguments[0].logdata);
              $scope.data2.push(arguments[0].tabledata);

          });

          $scope.data = [];
          $scope.data.push($scope.data1);
          $scope.data.push($scope.data2);

      }

        )

    $http.get('/JobTableMactchData/ishavematchtable/' + $scope.urlParm).success(
        function (data) {

            var i = 1
            for (i; i < 32 ;i++)
            {
                $scope.labels.push(i);
            };
            $scope.series = ['Series A', 'Series B'];
            $scope.data = [
              [65, 59, 80, 81, 56, 55, 40],
              [28, 48, 40, 19, 86, 27, 90]
            ];
            $scope.d0_1 = [[0, 7], [1, 6.5], [2, 12.5], [3, 7], [4, 9], [5, 6], [6, 11], [7, 6.5], [8, 8], [9, 7]];
            if (data == false) {
                $scope.message = ['error', 'Sorry no data'];
                showModal.toopen('sm', $scope.message);
                $state.go('app.filejoblog');

            }
            else {
                /*
                var nowTime = new Date();
                var theBeginDate = Date(nowTime.getYear, nowTime.getMonth - 1, 1);
                var theEndDate = nowTime;
                var jobDataModel = { JobName: $scope.urlParm, TheBeginDate: '2016-03-01', TheEndDate: '2016-03-08' };
                $http.post('/api/JobTableMactchData', jobDataModel).success(
                  function (data) {
                      $scope.datatotaljob = [];
                      $scope.datatotaltable = [];
                      $scope.data1=[]
                      $scope.data2=[]
                      data.forEach(function () {
                          if(arguments[0].logdata==null)
                          {
                              arguments[0].logdata = 0;
                          }
                           if(arguments[0].logdata==null)
                          {
                              arguments[0].logdata = 0;
                          }
                        //  $scope.datatotaljob.push([arguments[0].theday, arguments[0].logdata]);
                         // $scope.datatotaltable.push([arguments[0].theday, arguments[0].tabledata]);
                          $scope.data1.push(arguments[0].logdatay);
                          $scope.data2.push(arguments[0].tabledata);

                      });
                      
                      $scope.data = [];
                      $scope.data.push($scope.data1);
                      $scope.data.push($scope.data2);

                  }

                    )
                */
            }

        }
        );//success

    $scope.datatotal_test = [
            { data: [[0, 11], [1, 11], [2, 11], [3, 11], [4, 90], [5, 60], [6, 110], [7, 11], [8, 11], [9, 11]], label: 'A', points: { show: true, radius: 4 }, lines: { show: true, fill: true, fillColor: { colors: [{ opacity: 0.1 }, { opacity: 0.1 }] } } },
            { data: [[0, 11], [1, 11], [2, 11], [3, 11], [4, 3], [5, 30.5], [6, 60], [7, 11], [8, 11], [9, 11]], label: 'B', points: { show: true, radius: 2 } }
    ];
    $scope.datatshowconfig = {
        colors: ['#23b7e5', '#fad733'],
        series: { shadowSize: 2 },
        xaxis: { font: { color: '#ccc' } },
        yaxis: { font: { color: '#ccc' } },
        grid: { hoverable: true, clickable: true, borderWidth: 0, color: '#ccc' },
        tooltip: true,
        tooltipOpts: { content: '%s of %x.1 is %y.4', defaultTheme: false, shifts: { x: 0, y: 20 } }
    };


}])