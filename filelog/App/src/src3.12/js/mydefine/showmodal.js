angular.module('app')
    .controller('showModalInstanceCtrl', ['$scope', '$modalInstance', 'myitems', function ($scope, $modalInstance, myitems) {
        $scope.myitems = myitems;
        // $scope.myitems = ['successbc', 'Hi Save Success'];
        //only for test show
        $scope.success = 'successab';
        $scope.ok = function () {
            $modalInstance.close();
        };
    }]).service('showModal', ['$modal', function ($modal) {


        return {
            toopen: function (size, mydefineitmes) {

                var modalInstance = $modal.open({
                    templateUrl: 'splus/commonmodal.html',
                    controller: 'showModalInstanceCtrl',
                    size: size,
                    resolve: {
                        myitems: function () {
                            return mydefineitmes;
                        }
                    }
                })
            }
        };


    }])