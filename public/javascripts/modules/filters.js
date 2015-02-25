(function() {
  var app;

  app = angular.module('filters', []);

  app.factory('langDict', function() {
    return {
      'en': 'English',
      'en-us': 'English (US)',
      'en-uk': 'English (UK)',
      'de': 'German',
      'de-de': 'German (Germany)'
    };
  });

  app.filter('headerLanguages', function(langDict) {
    var replaceLangs;
    replaceLangs = function(langArray) {
      var a, key, l;
      a = [];
      l = langArray.length;
      while (l--) {
        key = langArray[l].toLowerCase();
        if (langDict[key]) {
          a.unshift(langDict[key]);
        } else {
          a.unshift(langArray[l]);
        }
      }
      return a;
    };
    return function(langs) {
      var a;
      if (langs) {
        a = langs.split(';');
        a = a[0].split(',');
        return replaceLangs(a);
      }
    };
  });

}).call(this);
