angular.module('user.chartProc', ['app'])
.controller('chartProcCtr', ['$scope', '$http', '$stateParams', '$modal', '$state', 'showModal', function ($scope, $http, $stateParams, $modal, $state, showModal) {
    //'showModal'
    $scope.urlParm = $stateParams.fold;
    $scope.datatotal = [];
   // $scope.avb = [[0, 11], [1, 11], [2, 11], [3, 11], [4, 90], [5, 60], [6, 110], [7, 11], [8, 11], [9, 11]];

    $http.post('chardata.js').success(
                 function (data) {
                     $scope.datatotaljob = [];
                     $scope.datatotaltable = [];
                     data.forEach(function () {
                         if (arguments[0].logdata == null) {
                             arguments[0].logdata = 0;
                         }
                         if (arguments[0].logdata == null) {
                             arguments[0].logdata = 0;
                         }
                         $scope.datatotaljob.push([arguments[0].theday, arguments[0].logdata]);
                         $scope.datatotaltable.push([arguments[0].theday, arguments[0].tabledata]);

                     });
                     $scope.avb = [[0, 11], [1, 11], [2, 11], [3, 11], [4, 90], [5, 60], [6, 110], [7, 11], [8, 11], [9, 11]];
                    // $scope.avg = [[0, 11], [1, 11], [2, 11], [3, 11], [4, 3], [5, 30.5], [6, 60], [7, 11], [8, 11], [9, 11]];
                    

                 }

                   );
    $http.get('testtrue.js').success(


        function (data) {
            if (data == false) {
                $scope.message = ['error', 'Sorry no data'];


                showModal.toopen('sm', $scope.message);
                $state.go('app.filejoblog');

            }
            else {
                var nowTime = new Date();
                var theBeginDate = Date(nowTime.getYear, nowTime.getMonth - 1, 1);
                var theEndDate = nowTime;
                var jobDataModel = { JobName: $scope.urlParm, TheBeginDate: '2016-03-01', TheEndDate: '2016-03-08' };
               

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