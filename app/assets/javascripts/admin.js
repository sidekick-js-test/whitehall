//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require vendor/jquery/jquery.player.min.js
//= require bootstrap
//= require_tree ./common
//= require ./application/toggler.js
//= require_tree ./admin


$(function(){

  $('.default-text .default a').click(function(e){
    var $this = $(this).closest('.default-text'),
        placeholder = $this.find('.default').hide(),
        fields = $this.find('.fields').show();

    $this.find(".chzn-select:visible").chosen({allow_single_deselect: true, search_contains: true});
    $this.find(".chzn-select-no-deselect:visible").chosen({allow_single_deselect: false, search_contains: true});
  });





});
