"use strict";
var app = {
  // Application Constructor
  initialize: function() {

    var host_server_rest = 'http://sumosuggest.com';

    var SumoSuggestApp = angular.module('SumoSuggestApp', ["datatables", 'datatables.select', "ngResource", "angular-clipboard", 'ngSanitize', 'ngCsv']);

    SumoSuggestApp.controller('HomeController', function($scope, $resource, DTOptionsBuilder, DTColumnDefBuilder, DTColumnBuilder, clipboard, $compile){  
      $scope.category = "search";
      $scope.country = "en-US";
      $scope.search_text = "";
      $scope.demo = true;
      $scope.loading = false;
      $scope.dtInstance = null;
      $scope.selected = {};
      $scope.selectAll = false;
      $scope.indexSearch = false;
      $scope.DataArray = [];

      var titleHtml = '<div class="checkbox checkbox-inline checkbox-styled ng-scope"><label><input type="checkbox" ng-model="selectAll" ng-click="toggleAll(selectAll, selected)"><span></span></label></div>';

      $scope.dtOptions = DTOptionsBuilder.fromSource('/search?keyword_text='+$scope.search_text+'&category='+$scope.category+'&country='+$scope.country)
          .withOption('stateSave', true)
          .withPaginationType('simple')
          .withDisplayLength(10);

      $scope.dtColumns = [
        DTColumnBuilder.newColumn(null).withTitle(titleHtml).notSortable()
          .renderWith(function(data, type, full, meta) {
            $scope.selected[full.id] = false;
            return '<div class="checkbox checkbox-inline checkbox-styled ng-scope"><label><input type="checkbox" ng-model="selected[' + data.id + ']" ng-click="toggleOne(selected)"><span></span></label></div>';
          }),
        DTColumnBuilder.newColumn('keywords').withTitle("Keywords"),
        DTColumnBuilder.newColumn('volumen').withTitle("Volumen"),
        DTColumnBuilder.newColumn('cpc').withTitle("CPC"),
        DTColumnBuilder.newColumn('competitions').withTitle("Competitions"),
      ];


      $scope.validator = $("#SearchForm").validate({
        rules: {
          select2: {
            required: true
          },
          search_text: {
            required: true
          }
        }
      });

      $scope.categoryBar = function(category){
        $scope.category = category;
      };

      $scope.dtIntanceCallback = function (instance) {
        $scope.dtInstance = instance;
        instance.DataTable.on('draw.dt', () => {
            let elements = angular.element("#" + instance.id + " .ng-scope");
            angular.forEach(elements, (element) => {
                $compile(element)($scope)
            });
        });
      };

      $scope.searchBtn = function(){

        if($scope.search_text!='' && $scope.country!='' && $scope.category!=''){

          // $scope.dtInstance.changeData('/search?keyword_text='+$scope.search_text+'&category='+$scope.category+'&country='+$scope.country);

          // $scope.dtInstance.reloadData(function callback(json) {
          //   console.log(json);
          // }, false);
        }else{
          alert('You must insert at less a search text');
        }
        
      };

      $scope.toggleAll = function(selectAll, selectedItems) {
          for (var id in selectedItems) {
              if (selectedItems.hasOwnProperty(id)) {
                  selectedItems[id] = selectAll;
              }
          }
      };

      $scope.toggleOne = function(selectedItems) {
          for (var id in selectedItems) {
              if (selectedItems.hasOwnProperty(id)) {
                  if(!selectedItems[id]) {
                      $scope.selectAll = false;
                      return;
                  }
              }
          }
          $scope.selectAll = true;
      };

      $scope.initSlider = function () {

        $('#rootwizard').bootstrapWizard({
          onNext: function(tab, navigation, index) {
            var $valid = $("#SearchForm").valid();
            if(!$valid) {
              $scope.validator.focusInvalid();
              return false;
            }
            handleTabShow(tab, navigation, index, $('#rootwizard'));
          }
        });

      };


      function handleTabShow(tab, navigation, index, wizard){

        if(index==2) $scope.indexSearch = true;
        else $scope.indexSearch = false;

        var total = navigation.find('li').length;
        var current = index + 0;
        var percent = (current / (total - 1)) * 100;
        var percentWidth = 100 - (100 / total) + '%';
        
        navigation.find('li').removeClass('done');
        navigation.find('li.active').prevAll().addClass('done');
        
        wizard.find('.progress-bar').css({width: percent + '%'});
        $('.form-wizard-horizontal').find('.progress').css({'width': percentWidth});
      };

      $scope.getClickBoard = function () {
        var str = "";
        var data = getSelectedData();
        for (var row in data) {
          str += data[row].keywords + ";" + data[row].volumen + ";" + data[row].cpc + ";" + data[row].competitions + "\n";
        }
        clipboard.copyText(str);

        toastr.options.hideDuration = 0;
        toastr.clear();
        toastr.options.closeButton = false;
        toastr.options.progressBar = false;
        toastr.options.debug = false;
        toastr.options.positionClass = 'toast-top-center';
        toastr.options.showDuration = 333;
        toastr.options.hideDuration = 333;
        toastr.options.timeOut = 3000;
        toastr.options.extendedTimeOut = 3000;
        toastr.options.showEasing = 'swing';
        toastr.options.hideEasing = 'swing';
        toastr.options.showMethod = 'slideDown';
        toastr.options.hideMethod = 'slideUp';
        toastr.info('Copy to clipboard', '');
        return true;
      };

      function getSelectedData(){
        var dt = $scope.dtInstance.dataTable.fnGetData();
        var result = [];
        for (var row in dt) {
          if($scope.selected[dt[row].id]){
            result.push(dt[row]);
          }
        }
        return result;
      }

      $scope.getCsv = function(){
        var d = [];
        var data = getSelectedData();
        for (var row in data) {
          d.push([data[row].keywords, data[row].volumen, data[row].cpc, data[row].competitions]);
        }
        return d;
      };

      $scope.initSlider();

    });

  },
  onLoad: function() {
      
  },
};




