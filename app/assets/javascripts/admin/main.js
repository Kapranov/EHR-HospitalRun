//= require application
//= require ui/main
//= require helpers/zipcode

$(document).ajaxStart(function(e) {
  NProgress.start();
});

$(document).ajaxStop(function() {
  NProgress.done();
});

$(document).ready(function() {
  initModalsReposition();

  var UsersTreeViewController = function() {
    var btn, parent;
    
    this.initialize = function(_btn, _parent) {
      btn = $(_parent + ' ' + _btn);
      btn.data('expanded', false);
      parent = _parent;
      initAll();
    };

    function initAll() {
      btn.click(function(e) {
        e.preventDefault();
        var tbody = $(this).closest('table.table-users').find('tbody:not(.main)[data-id="' + $(this).closest('tbody.main').data('id') + '"]');
        if(!$(this).data('expanded')) {
          $(this).data('expanded', true);
          tbody.fadeIn('fast');
          $(this).find('.fa').removeClass('fa-plus-square');
          $(this).find('.fa').addClass('fa-minus-square');
        }
        else {
          $(this).data('expanded', false);
          tbody.fadeOut('fast');
          $(this).find('.fa').addClass('fa-plus-square');
          $(this).find('.fa').removeClass('fa-minus-square');
        }
        tbody.toggleClass('expanded');
      });

      $(parent + ' ' + 'table.table-users tbody.main .checkbox-custom input[type="checkbox"]').change(function() {
        $(this).closest('tbody.main').find('.checkbox-custom input[type="checkbox"]').removeClass('checked-partial');
        var checkboxes = $(this).closest('table.table-users').find('tbody:not(.main)[data-id="'+$(this).closest('tbody.main').data('id')+'"] .checkbox-custom input[type="checkbox"]');
        if($(this).is(':checked'))
          checkboxes.prop('checked', true);
        else
          checkboxes.prop('checked', false);
      });

      $(parent + ' ' + 'table.table-users tbody:not(.main) .checkbox-custom input[type="checkbox"]').change(function() {
        var checkboxesCount = $(this).closest('table.table-users').find('tbody.child-user[data-id="'+ $(this).closest('tbody.child-user:not(.main)').data('id') +'"] .checkbox-custom input[type="checkbox"]').size();
        var checkboxesCheckedCount = $(this).closest('table.table-users').find('tbody.child-user[data-id="'+ $(this).closest('tbody.child-user:not(.main)').data('id') +'"] .checkbox-custom input[type="checkbox"]:checked').size();
        
        if(checkboxesCheckedCount < checkboxesCount)
          $(this).closest('table.table-users').find('tbody.main[data-id="'+ $(this).closest('tbody.child-user:not(.main)').data('id') +'"] .checkbox-custom input[type="checkbox"]').addClass('checked-partial');
        if(checkboxesCheckedCount == checkboxesCount) {
          $(this).closest('table.table-users').find('tbody.main[data-id="'+ $(this).closest('tbody.child-user:not(.main)').data('id') +'"] .checkbox-custom input[type="checkbox"]').removeClass('checked-partial');
          $(this).closest('table.table-users').find('tbody.main[data-id="'+ $(this).closest('tbody.child-user:not(.main)').data('id') +'"] .checkbox-custom input[type="checkbox"]').prop('checked', true).change();
        }
        if(checkboxesCheckedCount == 0) {
          $(this).closest('table.table-users').find('tbody.main[data-id="'+ $(this).closest('tbody.child-user:not(.main)').data('id') +'"] .checkbox-custom input[type="checkbox"]').prop('checked', false).change();
        }
      })
    };
  };

  var usersTreeViewController = new UsersTreeViewController();
  usersTreeViewController.initialize('a.user-child-expand', '#users-wrapper');
});