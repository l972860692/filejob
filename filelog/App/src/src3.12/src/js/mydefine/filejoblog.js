angular.module('user.filejoblog', ['ui.bootstrap'])
 .controller('myModalInstanceCtrl', ['$scope', '$modalInstance', 'myitems', function ($scope, $modalInstance,myitems) {
     $scope.myitems = myitems;
     // $scope.myitems = ['successbc', 'Hi Save Success'];
     //only for test show
     $scope.success = 'successab';
     $scope.ok = function () {
         $modalInstance.close();
     };
    }])
.controller('filejoblog.setting', ['$scope', '$http', '$modal' ,function ($scope, $http, $modal) {

    $scope.selected = undefined;
    $scope.allBaseData = undefined;
    $scope.jobTables = [];//for from back
    $scope.allSelectTables = [];//for web select table

    $scope.open = function (size) {

        var modalInstance = $modal.open({
            templateUrl: 'splus/commonmodal.html',
            controller: 'myModalInstanceCtrl',
            size: size,
            resolve: {
                myitems: function () {
                    return $scope.myitems;
                }
            }
        })
    };

    $scope.myitems = [];

    $scope.toSave = function () {

        var backData = [];
        $scope.jobTables.forEach(
            function () {
                var tempJobTable = { jobName: arguments[0].jobName, tableName: arguments[0].tableName }
                backData.push(tempJobTable);
            }
            );
        $http.post('/api/FileJobTableName', backData ).success(function () {
           //  $scope.items = { status: success, message: 'Hi Save Success' };
            var n = 1;
            $scope.myitems = ['success',  'Hi Save Success' ];
            $scope.open();

        }).
  error(function () {
      // $scope.items = { status: error, message: 'Sorry Some mistaken happen' };
      $scope.myitems = ['error', 'Sorry Some mistaken happen'];
       $scope.open();
  });

    }
    $http.get('/api/FileJobTableName').success(


        function (data) {
            $scope.allBaseData = data;

            //tableable get all table name if table have jobname let it h
            $scope.allBaseData.tablenames.forEach(function (item) {

                var tempSelectTable = { id: -1, jobName: undefined, tableName: arguments[0], indexId: arguments[1], selected: false, isDisable: false };
                data.fileJobTableHadMatch.some(function () {
                    if (item == arguments[0].tablename) {
                        //tempSelectTable.id = arguments[0].id;
                        tempSelectTable.jobName = arguments[0].jobname;
                        tempSelectTable.selected = true;
                    }
                    return item == arguments[0].tablename;

                })

                $scope.allSelectTables.push(tempSelectTable);

            })
            //jobname
            $scope.allBaseData.filenames.forEach(
                function (item) {
                    var tempJobTable = { id: -1, jobName: item, tableName: undefined, indexId: arguments[1], selected: false };
                    data.fileJobTableHadMatch.some(function () {
                        if (item == arguments[0].jobname) {
                            tempJobTable.id = arguments[0].id;
                            tempJobTable.tableName = arguments[0].tablename
                            tempJobTable.selected = true;

                        }
                        return item == arguments[0].jobname;

                    })

                    $scope.jobTables.push(tempJobTable);

                }
                );

        }
        )//ajax over


    $scope.toChangeJobName = function (item) {

        if (arguments[1] == true) {
            item.tableName = undefined;
        }
        //item job-table
        // item.selected = false;
        //we sure to set backjobname=undefined if have or not
        $scope.allSelectTables.forEach(function (data) {
            if (data.jobName == item.jobName) {
                data.jobName = undefined;
                return;
            }


        })
        //then we would set table
        $scope.allSelectTables.forEach(function (data) {
            if (item.tableName != undefined && data.tableName == item.tableName) {
                data.jobName = item.jobName;
                return;
            }


        })




    }
    //
    $scope.selectChange = function (jobName, tableName, jobTables) {


        for (var i = 0; i < $scope.jobTables.length; i++) {
            if ($scope.jobTables[i].jobName == jobName) {
                $scope.jobTables[i].tableName = tableName;
                var tempJobTable = { id: jobTables.id, jobName: jobName, tableName: tableName, indexId: tableName.indexId };
                $scope.jobTables.splice(i, 1, tempJobTable).sort();

                $scope.allSelectTables = [];
                $scope.allBaseData.tablenames.forEach(function (item) {

                    var tempSelectTable = { id: -1, jobName: '-1', tableName: arguments[0], indexId: arguments[1], selected: false, isDisable: false };
                    $scope.jobTables.filter(
                        function (jobTable)
                        { return jobTable.tableName != undefined }
                        ).forEach(function () {
                            if (item == arguments[0].tablename) {
                                //tempSelectTable.id = arguments[0].id;
                                tempSelectTable.jobName = arguments[0].jobname;

                            }


                        })

                    $scope.allSelectTables.push(tempSelectTable);
                }

)

                return;
            }
        }


    }
    //ng-selected="selectNCC(jobTable.tableName,r.tableName)"
    $scope.selectNCC = function (name, item) {
        if (name == item) {
            return true;
        }
        return false;
    }

    //ng-disabled="isCanSelect(jobTable.tableName,r.tableName)"
    $scope.isCanSelect = function (name, item) {
        //不要再此次进行evary 判断
        if (name != item.tablename && item.jobname != '-1') {
            return true;
        }
        return false;
    }


}])