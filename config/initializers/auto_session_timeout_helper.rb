module AutoSessionTimeoutHelper
  def auto_session_timeout_js(options={})
    frequency = options[:frequency] || 60
    remote = options[:remote] || false
    code = <<JS
if (typeof(Ajax) != 'undefined') {
  new Ajax.PeriodicalUpdater('', '/active', {frequency:#{frequency}, method:'get', onSuccess: function(e) {
    if (e.responseText == 'false') window.location.href = '/timeout';
  }});
} else {
  $.PeriodicalUpdater('/active', {minTimeout:#{frequency * 1000}, multiplier:0, method:'get', verbose:2}, function(remoteData, success) {
    if (success == 'success' && remoteData == 'false') {
      #{remote ? '$.ajax({url: "/timeout"});' : 'window.location.href = "/timeout";'}
    }
  });
}
JS
    javascript_tag(code)
  end
end

ActionView::Base.send :include, AutoSessionTimeoutHelper