class DayTime {
  var hour;
  var minutes;
  var seconds;

  function initialize(hour, minutes, seconds) {
    self.hour = hour;
    self.minutes = minutes;
    self.seconds = seconds;
  }

  function toRad(noon) {
    var timeDeg = self.hour * 15.0 + self.minutes / 4.0;
    var noonDeg = noon.hour * 15.0 + noon.minutes / 4.0;
    return Math.toRadians(90.0 + noonDeg - timeDeg);
  }

  function lowerThan(t) {
    if (self.hour * 60 + self.minutes < t.hour * 60 + t.minutes) {
      return true;
    }
    return false;
  }

  function greaterThan(t) {
    if (self.hour * 60 + self.minutes > t.hour * 60 + t.minutes) {
      return true;
    }
    return false;
  }
}
