function pwgen(name, len) {
  var elt = document.getElementById(name);
  if (!elt)
    return;

  var chars = 'abcdefghjkmnpqrstuvwxyz23456789';
  var pw = '';
  for (var i = 0; i < len; i++) {
    pw += chars[Math.floor(Math.random()*chars.length)];
  }
  elt.value = pw;
}
