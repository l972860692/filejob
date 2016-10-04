angular.module('user.filejoblog', ['ui.bootstrap'])
 .controller('myModalInstanceCtrl', ['$scope', '$modalInstance', 'myitems', function ($scope, $modalInstance, myitems) {
     //for modal . this is first use .next  i would  give a service to seal it more easy to use
     $scope.myitems = myitems;
     //only for test show
     $scope.success = 'successab';
     $scope.ok = function () {
         $modalInstance.close();
     };
 }])
.controller('filejoblog.setting', ['$scope', '$http', '$modal', function ($scope, $http, $modal) {

    $scope.selected = undefined;
    $scope.jobMacthTables = [];//for web show jobname and would contain the selected result , base on it return selected data to server.
    $scope.allCanSelectTables = [];//for web ,it can  select table base on jobname.

    //for modal . this is first use .next  i would  give a service to seal it more easy to use
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
    //get the select result to back server
    $scope.toSave = function () {

        var backData = [];
        $scope.jobMacthTables.forEach(
            function () {
                var tempJobTable = { jobName: arguments[0].jobName, tableName: arguments[0].tableName }
                backData.push(tempJobTable);
            }
            );
        $http.post('/api/JobTableName', backData).success(function () {
            //  $scope.items = { status: success, message: 'Hi Save Success' };
            var n = 1;
            $scope.myitems = ['success', 'Hi Save Success'];
            $scope.open();

        }).
  error(function () {
      // $scope.items = { status: error, message: 'Sorry Some mistaken happen' };
      $scope.myitems = ['error', 'Sorry Some mistaken happen'];
      $scope.open();
  });

    }


    $http.get('/api/JobTableName').success(
        function (data) {
            $scope.allBaseData = data;//just for temp =data
            //make the $scope.allCanSelectTables get it values
            $scope.allBaseData.tablenames.forEach(function (item) {
                var tempSelectTable = { id: -1, jobName: undefined, tableName: arguments[0], indexId: arguments[1], selected: false, isDisable: false };
                //if the job have match table let the obj get some value like jobName. then we can first can the file had match the table and orders can't be choose it
                data.fileJobTableHadMatch.some(function () {
                    if (item == arguments[0].tableName) {
                        tempSelectTable.jobName = arguments[0].jobName;
                        tempSelectTable.selected = true;
                    }
                    return item == arguments[0].tableName;

                })

                $scope.allCanSelectTables.push(tempSelectTable);

            })
            //make the $scope.jobMacthTables get it values 
            $scope.allBaseData.jobnames.forEach(
                function (item) {
                    var tempJobTable = { id: -1, jobName: item, tableName: undefined, indexId: arguments[1], selected: false };
                    // if the job had match table  let it show 
                    data.fileJobTableHadMatch.some(function () {
                        if (item == arguments[0].jobName) {
                            tempJobTable.id = arguments[0].id;
                            tempJobTable.tableName = arguments[0].tableName
                            tempJobTable.selected = true;
                        }
                        return item == arguments[0].jobName;

                    })

                    $scope.jobMacthTables.push(tempJobTable);

                }
                );
            $scope.allBaseData = null;
        }
        )//ajax over

    //item:jobTable (当传第二个参数时true时用作清空判断)
    //当change时 1.首先 让$scope.allCanSelectTables 其以前匹配项清空 如果有的话。2.然后重新设置其匹配项条件为真的选择了匹配的table而不是置空。
    $scope.toChangeJobName = function (item) {
        if (arguments[1] == true) {
            item.tableName = undefined;
        }
        //1.we sure to set backjobname=undefined if have or not
        $scope.allCanSelectTables.forEach(function (data) {
            if (data.jobName == item.jobName) {
                data.jobName = undefined;
                return;
            }

        })
        //2.then we would set table
        $scope.allCanSelectTables.forEach(function (data) {
            if (item.tableName != undefined && data.tableName == item.tableName) {
                data.jobName = item.jobName;
                return;
            }

        })


    }
    //ng-selected="selectNCC(jobTable.tableName,r.tableName)"
    $scope.toMackeSelected = function (name, item) {
        if (name == item) {
            return true;
        }
        return false;
    }

    //ng-disabled="isCanSelect(jobTable.tableName,r.tableName)"



}])