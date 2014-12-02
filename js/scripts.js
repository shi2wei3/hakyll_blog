function mailTo(address) {
  return '<a href="mailto:' + address + '">' + address + '</a>';
}

function setEmail() {
  var user = '&#115;&#104;&#105;&#50;&#119;&#101;&#105;&#51;&#64;';
  var google = '&#103;&#109;&#97;&#105;&#108;&#46;&#99;&#111;&#109;';
  var hotmail = '&#104;&#111;&#116;&#109;&#97;&#105;&#108;&#46;&#99;&#111;&#109;';
  $('.google-email').html(mailTo(user + google));
  $('.hotmail-email').html(mailTo(user + hotmail));
}

function toggleAbstract(key) {
  $('.pub-abstract.'+key).slideToggle();
}
