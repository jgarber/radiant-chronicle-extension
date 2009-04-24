timeline_balloons = $A()
function attach_help_balloon(version_number, data_url) {
  node = $('version-'+version_number+'-icon');
  timeline_balloons[version_number] = new HelpBalloon({
    dataURL: data_url,
    icon: node,
    balloonPrefix: '/images/admin/balloon-',
    button: '/images/admin/button.png',
    contentMargin: 40,
    showEffect: Effect.Appear,
    hideEffect: Effect.Fade,
    autoHideTimeout: 2000
  });
}
function load_version_diff(url, diff_link) {
  popup = $('version-diff-popup');
  new Effect.Highlight(diff_link);
  req = new Ajax.Request(url, { method: 'get', evalScripts: true });
  return false;
}
