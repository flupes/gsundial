class DayTime {
  var hour;
  var minute;
  var seconds;

  function initialize(hour, minute, seconds) {
    self.hour = hour;
    self.minute = minute;
    self.seconds = seconds;
  }

  function toRad(noon) {
    var timeDeg = self.hour * 15.0 + self.minute / 4.0;
    var noonDeg = noon.hour * 15.0 + noon.minute / 4.0;
    return Math.toRadians(90.0 + noonDeg - timeDeg);
  }
}
