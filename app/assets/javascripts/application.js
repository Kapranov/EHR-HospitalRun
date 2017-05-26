//= require jquery2
//= require jquery_ujs
//= require bootstrap/bootstrap.min
//= require moment/moment
//= require bootstrap-datepicker-custom/bootstrap-datepicker-custom
//= require bootstrap-table/bootstrap-table
//= require jquery-inputmask/jquery.inputmask.bundle-custom
//= require jquery-validation/jquery.validate
//= require jquery-validation/additional-methods
//= require jquery-ui/jquery-ui-without-datepicker.min
//= require jquery-updater/jquery.periodicalupdater.js
//= require jquery-updater/jquery.updater.js
//= require nprogress-custom/nprogress-custom
//= require color-picker/tinycolor-0.9.15.min
//= require color-picker/color-picker
//= require fullcalendar/fullcalendar
//= require jquery-slimscroll-custom/jquery.slimscroll-custom
//= require select2-custom/select2-custom
//= require bootstrap-dropdowns-enhancement/dropdowns-enhancement
//= require jquery.minicolors
//= require jquery.minicolors.simple_form
//= require jquery-bridget/jquery-bridget
//= require jquery-magnificentjs/mag
//= require jquery-magnificentjs/mag-jquery

$(document).ajaxStart(function(e) {
  NProgress.start();
});

$(document).ajaxStop(function() {
  NProgress.done();
});