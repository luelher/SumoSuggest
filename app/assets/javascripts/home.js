var app = {
  // Application Constructor
  initialize: function() {

    var host_server_rest = 'http://rabmaleh.com';

    var SumoSuggestApp = angular.module('SumoSuggestApp', []);

    SumoSuggestApp.controller('HomeController', function($scope){  
      $scope.category = "search";
      $scope.country = "US";
      $scope.search_text = "";
      $scope.demo = true;
      $scope.loading = false;
      
      $scope.categoryBar = function(category){
        $scope.category = category;
      };

      $scope.searchBtn = function(){

        if($scope.search_text!='' && $scope.country!='' && $scope.category!=''){
          $scope.loading = true;
          $scope.demo = false;
        }else{
          alert('You must insert at less a search text');
        }
        
      };


    });

  },
  onLoad: function() {
      
  },
};




