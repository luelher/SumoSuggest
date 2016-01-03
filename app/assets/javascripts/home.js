var app = {
  // Application Constructor
  initialize: function() {

    var host_server_rest = 'http://rabmaleh.com';

    var SumoSuggestApp = angular.module('SumoSuggestApp', ["datatables", 'datatables.select', "ngResource"]);

    SumoSuggestApp.controller('HomeController', function($scope, $resource, DTOptionsBuilder, DTColumnDefBuilder, DTColumnBuilder){  
      $scope.category = "search";
      $scope.country = "en-US";
      $scope.search_text = "";
      $scope.demo = true;
      $scope.loading = false;
      $scope.dtInstance = null;
      $scope.selected = {};
      $scope.selectAll = false;
      $scope.toggleAll = toggleAll;
      $scope.toggleOne = toggleOne;

      var titleHtml = '<div class="checkbox checkbox-inline checkbox-styled"><label><input type="checkbox" ng-model="selectAll" ng-click="toggleAll(selectAll, selected)"><span></span></label></div>';


      $scope.categoryBar = function(category){
        $scope.category = category;
      };

      $scope.dtIntanceCallback = function (instance) {
        $scope.dtInstance = instance;
      }

      $scope.searchBtn = function(){

        if($scope.search_text!='' && $scope.country!='' && $scope.category!=''){
          
          if($scope.dtInstance==null){
            $scope.dtOptions = DTOptionsBuilder.fromSource('/search?keyword_text='+$scope.search_text+'&category='+$scope.category+'&country='+$scope.country).withOption('stateSave', true).withPaginationType('simple').withDisplayLength(10);
            $scope.dtColumns = [
              DTColumnBuilder.newColumn(null).withTitle(titleHtml).notSortable()
                .renderWith(function(data, type, full, meta) {
                  $scope.selected[full.id] = false;
                  return '<div class="checkbox checkbox-inline checkbox-styled"><label><input type="checkbox" ng-model="selected[' + data.id + ']" ng-click="toggleOne(selected)"><span></span></label></div>';
                }),              
              DTColumnBuilder.newColumn('keywords').withTitle("Keywords"),
              DTColumnBuilder.newColumn('volumen').withTitle("Volumen"),
              DTColumnBuilder.newColumn('cpc').withTitle("CPC"),
              DTColumnBuilder.newColumn('competitions').withTitle("Competitions"),
            ];            
          }else{
            $scope.dtOptions = DTOptionsBuilder.fromSource('/search?keyword_text='+$scope.search_text+'&category='+$scope.category+'&country='+$scope.country).withOption('stateSave', true).withPaginationType('simple').withDisplayLength(10);
            $scope.dtInstance.reloadData(function callback(json) {
              //console.log(json);
            }, false);
          }
          $scope.loading = false;
          $scope.demo = false;

        }else{
          alert('You must insert at less a search text');
        }
        
      };


      function toggleAll (selectAll, selectedItems) {
          for (var id in selectedItems) {
              if (selectedItems.hasOwnProperty(id)) {
                  selectedItems[id] = selectAll;
              }
          }
      }
      function toggleOne (selectedItems) {
          for (var id in selectedItems) {
              if (selectedItems.hasOwnProperty(id)) {
                  if(!selectedItems[id]) {
                      $scope.selectAll = false;
                      return;
                  }
              }
          }
          $scope.selectAll = true;
      }


    });

  },
  onLoad: function() {
      
  },
};




