// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function(){
  var timesheet = function(){
    $(document).on('click', '.worked-minus', this.subtractTime);
    $(document).on('click', '.worked-plus', this.addTime);
  }

  var timeout = null;

  var changeWorkedTarget = function(amt){
    var row = $(this).closest('tr'),
        worked = row.find('.worked_hours'),
        worked_hours = parseFloat(worked.text()),
        date = row.attr('data-date'),
        total_worked = $('.total_worked_hours'),
        total_worked_hours = parseFloat(total_worked.text()),
        total = $('.total_hours'),
        total_hours = parseFloat(total.text());

    worked_hours = (isNaN(worked_hours) ? 0 : worked_hours) + amt;
    total_worked_hours = (isNaN(total_worked_hours) ? 0 : total_worked_hours) + amt;
    total_hours = (isNaN(total_hours) ? 0 : total_hours) + amt;

    if(worked_hours >= 0){
      worked.html(worked_hours.toFixed(1));
      total_worked.html(total_worked_hours.toFixed(1));
      total.html(total_hours.toFixed(1));

      if(timeout){
        clearTimeout(timeout);
      }

      timeout = setTimeout(function(){
        timeout = null;
        console.log('sent ajax update');
      }, 500)
    }
  }

  timesheet.prototype.subtractTime = function(){
    changeWorkedTarget.call(this, -0.5);
  }

  timesheet.prototype.addTime = function(){
    changeWorkedTarget.call(this, 0.5);
  }

  window.Timesheet = new timesheet();
});
